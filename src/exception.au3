#include-once
#include "class.au3"

_Class_Register("__Exception", "___Exception_Constructor")

Func Exception($message = "", $code = 0, $previous = Null, $line = @ScriptLineNumber)
    Return _Class_New("__Exception", $message, $code, $previous, $line)
EndFunc

Func ___Exception_Constructor(ByRef $this, $message = "", $code = 0, $previous = Null, $line = -1)
    $this.message = $message
    $this.code = $code
    $this.previous = $previous
    $this.line = $line
EndFunc

Func __Exception_GetMessage(ByRef $this)
    Return $this.message
EndFunc

Func __Exception_GetCode(ByRef $this)
    Return $this.code
EndFunc

Func __Exception_GetLine(ByRef $this)
    Return $this.line
EndFunc

Func __Exception_GetPrevious(ByRef $this)
    Return $this.previous
EndFunc

#cs
Func __Exception_GetTrace(ByRef $this)
    Return $this.trace
EndFunc
#ce

Func __Exception_ToString(ByRef $this)
    Return StringFormat("%s: %s at line %d", _Class_GetName($this), $this.message, $this.line)
EndFunc
