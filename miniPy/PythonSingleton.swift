//
//  PythonSingleton.swift
//  miniPy
//
//  Created by Gui Andrade on 6/18/19.
//  Copyright © 2019 Gui Andrade. All rights reserved.
//

import Foundation
import iCustomPy

@_cdecl("post_stdout")
func postStdout(_self: UnsafeMutablePointer<PyObject>?, args: UnsafeMutablePointer<PyObject>?) -> UnsafeMutablePointer<PyObject>?
{
    let arg0 = PyTuple_GetItem(args, 0)
    
    var buf = Py_buffer()
    if PyObject_GetBuffer(arg0, &buf, PyBUF_CONTIG_RO) == 0 {
        
        let realBuf = [UInt8].init(unsafeUninitializedCapacity: buf.len, initializingWith: {(dstBuf, sizeWritten) in
            
            let C = Int8("C".first!.asciiValue!)
            let res = PyBuffer_ToContiguous(dstBuf.baseAddress, &buf, buf.len, C)
            assert(res == 0, "Failed to copy string buffer!")
            sizeWritten = buf.len
        })
        
        PythonSingleton.stdoutWriter?(realBuf)

        PyBuffer_Release(&buf)
    }
    
    Py_DecRef(arg0)
    Py_IncRef(&_Py_NoneStruct)
    return UnsafeMutablePointer(&_Py_NoneStruct)
}


class PythonSingleton {
    private static var activePythonHandle = OSAtomic_int64_aligned64_t(0)
    private static var pythonExecQueue = dispatch_queue_serial_t(label: "Python Exec Queue")
    static var stdoutWriter: ( ([UInt8]) -> Void )?
    
    static func asyncRequestStop(pyHandle: Int64) {
        var pyHandle = pyHandle

        Py_AddPendingCall({ pyHandlePtr in
            let pyHandle = pyHandlePtr!.load(as: Int64.self)
            if pyHandle != PythonSingleton.activePythonHandle {
                // Previous already returned and now we're onto a new interpreter
                return 0
            }
            if Py_IsInitialized() == 0 {
                // Shouldn't happen but let's check anyway
                return 0
            }
            PyErr_SetString(PyExc_KeyboardInterrupt, "System requested exit!")
            return 0
        }, &pyHandle)
    }
    
    static func waitForFinish() {
        pythonExecQueue.sync {} // Finish whatever might have been running earlier
    }
    
    private static func runInstance(text: String) {
        var flags = PyCompilerFlags()
        
        Py_Initialize()
        
        PyRun_SimpleStringFlags(
            """
            import sys
            class StdOut(object):
                def write(self, string):
                    if isinstance(string, str):
                        string = string.encode()
                    sys._post_stdout(string)
                def flush(self):
                    pass
            sys.stdout = StdOut()
            """, &flags)
        
        let sys_mod = PyImport_AddModule("sys");
        var postStdoutMethodDef = [
            PyMethodDef(ml_name: "_post_stdout",
                        ml_meth: postStdout,
                        ml_flags: METH_VARARGS,
                        ml_doc: nil),
            PyMethodDef()
        ]
        PyModule_AddFunctions(sys_mod, &postStdoutMethodDef)
        
        PyRun_SimpleStringFlags(text, &flags)
        
        Py_DecRef(sys_mod)
        
        if Py_FinalizeEx() < 0 {
            // Error
            assert(false, "Could not finalize interpreter!")
        }
    }
    
    static func asyncRunInstance(code: String) -> Int64 {
        let newHandle = OSAtomicAdd64(1, &activePythonHandle)
        pythonExecQueue.async {
            runInstance(text: code)
        }
        return newHandle
    }
}
