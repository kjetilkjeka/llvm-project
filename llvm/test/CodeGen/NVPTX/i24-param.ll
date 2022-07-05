; RUN: llc < %s -march=nvptx -mcpu=sm_20 -verify-machineinstrs | FileCheck %s
; RUN: %if ptxas %{ llc < %s -march=nvptx -mcpu=sm_20 -verify-machineinstrs | %ptxas-verify %}

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v32:32:32-v64:64:64-v128:128:128-n16:32:64"

; CHECK: .visible .func  (.param .b32 func_retval0) callee
; CHECK: .param .b32 callee_param_0
define i24 @callee(i24 %a) {
  %val = alloca i24, align 4
  store i24 %a, i24* %val, align 4
  %ret = load i24, i24* %val, align 1
; CHECK: ld.param.u8
; CHECK: ld.param.u16
; CHECK: st.param.b32
  ret i24 %ret
}

; CHECK: .visible .func caller
define void @caller(i24* %a) {
  %val = load i24, i24* %a
  %ret = call i24 @callee(i24 %val)
; CHECK: ld.param.b32
; CHECK: st.u16
; CHECK: st.u8
  store i24 %ret, i24* %a
  ret void
}
  