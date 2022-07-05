; RUN: llc < %s -march=nvptx -mcpu=sm_20 -verify-machineinstrs | FileCheck %s
; RUN: %if ptxas %{ llc < %s -march=nvptx -mcpu=sm_20 -verify-machineinstrs | %ptxas-verify %}

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v32:32:32-v64:64:64-v128:128:128-n16:32:64"

; CHECK: .visible .func  (.param .b64 func_retval0) callee
; CHECK: .param .b64 callee_param_0
define i48 @callee(i48 %a) {
  %val = alloca i48, align 8
  store i48 %a, i48* %val, align 8
  %ret = load i48, i48* %val, align 1
; CHECK: ld.param.u16
; CHECK: ld.param.u32
; CHECK: st.param.b64
  ret i48 %ret
}

; CHECK: .visible .func caller
define void @caller(i48* %a) {
  %val = load i48, i48* %a
  %ret = call i48 @callee(i48 %val)
; CHECK: ld.param.b64
; CHECK: st.u32
; CHECK: st.u16
  store i48 %ret, i48* %a
  ret void
}