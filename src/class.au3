#include-once

#cs
# Generate method call args string
#
# @param int $numberOfArgs
# @return string
#ce
Func __Class_Method_Call_Args($numberOfArgs)
    Local $result = ""
    For $i = 1 To $numberOfArgs
        $result = $result & ", $arg" & $i
    Next
    Return $result
EndFunc

#cs
# Check if class is registered
#
# @param string $sClassName
# @return bool
#ce
Func __Class_Exists($sClassName)
    Return MapExists($__Class_Classes, $sClassName)
EndFunc

#cs
# Create new class instance
#
# @param string $sClassName
# @param mixed $arg1
# @param mixed $arg2
# @param mixed $arg3
# @param mixed $arg4
# @param mixed $arg5
# @param mixed $arg6
# @param mixed $arg7
# @param mixed $arg8
# @param mixed $arg9
# @param mixed $arg10
# @return Class
#ce
Func _Class_New($sClassName, $arg1 = Null, $arg2 = Null, $arg3 = Null, $arg4 = Null, $arg5 = Null, $arg6 = Null, $arg7 = Null, $arg8 = Null, $arg9 = Null, $arg10 = Null, $line = @ScriptLineNumber)
    If Not __Class_Exists($sClassName) Then Return SetError(1, 0, Exception("Class not registered", 0, Null, $line))

    Local $this[]
        $this['@__ClassName__'] = $sClassName
    
    ; Constructor
    $expression = FuncName(__Class_Constructor_Call) & "($this" & __Class_Method_Call_Args(@NumParams - 1) & ")"
    Execute($expression)

    Return $this
EndFunc

#cs
# Call constructor
#
# @param Class $this
# @param mixed $arg1
# @param mixed $arg2
# @param mixed $arg3
# @param mixed $arg4
# @param mixed $arg5
# @param mixed $arg6
# @param mixed $arg7
# @param mixed $arg8
# @param mixed $arg9
# @param mixed $arg10
# @return void
#ce
Func __Class_Constructor_Call(ByRef $this, $arg1 = Null, $arg2 = Null, $arg3 = Null, $arg4 = Null, $arg5 = Null, $arg6 = Null, $arg7 = Null, $arg8 = Null, $arg9 = Null, $arg10 = Null, $line = @ScriptLineNumber)
    If Not __Class_Exists($this['@__ClassName__']) Then Return SetError(1, 0, Exception("Class not registered", 0, Null, $line))

    Local $mClass = $__Class_Classes[$this['@__ClassName__']]

    Local $fnConstructor = $mClass['Constructor']

    If Null = $fnConstructor Then Return SetError(0, 1, Exception("Class has no constructor", 0, Null, $line))
    Local $fnConstructor = $mClass['Constructor']

    Local $expression = FuncName($fnConstructor) & "($this" & __Class_Method_Call_Args(@NumParams - 1) & ")"
    Local $result = Execute($expression)

    Return SetError(@error, @extended)
EndFunc

#cs
# Get parent constructor
#
# @param string $className
# @return callable|null
#ce
Func __Class_Parent_Constructor_Get($className)
    Local $mClass = $__Class_Classes[$className]
    Local $parentClassName = $mClass['Extends']
    If Null = $parentClassName Then Return Null

    Local $mParentClass = $__Class_Classes[$parentClassName]
    Local $parentConstructor = $mParentClass['Constructor']
    If Not (Null = $parentConstructor) Then Return $parentConstructor

    Return __Class_Parent_Constructor_Get($parentClassName)
EndFunc

#cs
# Call parent constructor
#
# @param Class|string $this
# @param mixed $arg1
# @param mixed $arg2
# @param mixed $arg3
# @param mixed $arg4
# @param mixed $arg5
# @param mixed $arg6
# @param mixed $arg7
# @param mixed $arg8
# @param mixed $arg9
# @param mixed $arg10
# @return void
#ce
Func _Class_Parent_Constructor_Call(ByRef $this, $arg1 = Null, $arg2 = Null, $arg3 = Null, $arg4 = Null, $arg5 = Null, $arg6 = Null, $arg7 = Null, $arg8 = Null, $arg9 = Null, $arg10 = Null, $line = @ScriptLineNumber)
    Local $constructor = __Class_Parent_Constructor_Get($this['@__ClassName__'])

    If Null = $constructor Then Return SetError(0, 1, Exception("Class has no parent constructor", 0, Null, $line))

    $expression = FuncName($constructor) & "($this" & __Class_Method_Call_Args(@NumParams - 1) & ")"
    $result = Execute($expression)

    Return SetError(@error, @extended)
EndFunc

Global $__Class_Classes[]

#cs
# Register a class
#
# @param string $sClassName
# @param callable|null $fnConstructor
# @param string $sExtends
# @return Class
#ce
Func _Class_Register($sClassName, $fnConstructor = Null, $sExtends = Null, $line = @ScriptLineNumber);, $aImplements = Null, $aTraits = Null)
    If MapExists($__Class_Classes, $sClassName) Then Return SetError(1, 0, Exception("Class already registered", 0, Null, $line))
    If Not (Null = $sExtends) And Not MapExists($__Class_Classes, $sExtends) Then Return SetError(1, 0, Exception("Class to extend not registered", 0, Null, $line))

    If IsString($fnConstructor) Then $fnConstructor = Execute($fnConstructor)

    Local $mClass[]
        $mClass['ClassName'] = $sClassName
        $mClass['Constructor'] = $fnConstructor
        $mClass['Extends'] = $sExtends
        ;$mClass['Implements'] = $aImplements
        ;$mClass['Traits'] = $aTraits

    $__Class_Classes[$sClassName] = $mClass

    Return $mClass
EndFunc

#cs
# Get class method
#
# @param Class|string $this
# @param string $methodName
# @return callable|null
#ce
Func __Class_Method_Get(ByRef $this, $methodName)
    Local $mClass = $__Class_Classes[$this['@__ClassName__']]
    Local $sClassName = $mClass['ClassName']
    Local $fnMethod = Execute($sClassName&"_"&$methodName)

    If IsFunc($fnMethod) Then Return $fnMethod

    Local $sExtends = $mClass['Extends']
    If Not (Null = $sExtends) Then
        Local $parentThis = $this
        $parentThis['@__ClassName__'] = $sExtends
        Return __Class_Method_Get($parentThis, $methodName)
    EndIf

    Return Null
EndFunc

#cs
# Get class static method
#
# @param string $this
# @param string $methodName
# @return callable|null
#ce
Func __Class_StaticMethod_Get($this, $methodName)
    Local $mClass = $__Class_Classes[$this]
    Local $sClassName = $mClass['ClassName']
    Local $fnMethod = Execute($sClassName&"_static_"&$methodName)

    If IsFunc($fnMethod) Then Return $fnMethod

    Local $sExtends = $mClass['Extends']
    If Not (Null = $sExtends) Then
        Return __Class_StaticMethod_Get($sExtends, $methodName)
    EndIf

    Return Null
EndFunc

#cs
# Call class method
#
# @param Class|string $this
# @param string $methodName
# @param mixed $arg1
# @param mixed $arg2
# @param mixed $arg3
# @param mixed $arg4
# @param mixed $arg5
# @param mixed $arg6
# @param mixed $arg7
# @param mixed $arg8
# @param mixed $arg9
# @param mixed $arg10
# @return mixed
#ce
Func _Class_Method_Call(ByRef $this, $methodName, $arg1 = Null, $arg2 = Null, $arg3 = Null, $arg4 = Null, $arg5 = Null, $arg6 = Null, $arg7 = Null, $arg8 = Null, $arg9 = Null, $arg10 = Null, $line = @ScriptLineNumber)
    Local $fnMethod = __Class_Method_Get($this, $methodName)
    If Null = $fnMethod Then Return SetError(1, 0, Exception("Method not found", 0, Null, $line))

    Local $expression = FuncName($fnMethod)&"($this"& __Class_Method_Call_Args(@NumParams - 2) & ")"
    Local $result = Execute($expression)

    Return SetError(@error, @extended, $result)
EndFunc

#cs
# Get class property
#
# @param Class|string $this
# @param string $propertyName
# @return mixed
#ce
Func _Class_Property_Get(ByRef $this, $propertyName, $line = @ScriptLineNumber)
    Return MapExists($this, $propertyName) ? $this[$propertyName] : SetError(1, 0, Exception("Property not found", 0, Null, $line))
EndFunc

#cs
# Get static class method
#
# @param Class|string $this
# @param string $methodName
# @return mixed
#ce
Func _Class_StaticMethod_Call($this, $methodName, $arg1 = Null, $arg2 = Null, $arg3 = Null, $arg4 = Null, $arg5 = Null, $arg6 = Null, $arg7 = Null, $arg8 = Null, $arg9 = Null, $arg10 = Null, $line = @ScriptLineNumber)
    If IsMap($this) Then $this = $this['@__ClassName__']

    $fn = __Class_StaticMethod_Get($this, $methodName)
    If Null = $fn Then Return SetError(1, 0, Exception("Static method """ & $methodName & """ on class """ & $this & """ not found", 0, Null, $line))

    Local $expression = FuncName($fn)&"($this"& __Class_Method_Call_Args(@NumParams - 2) & ")"
    Local $result = Execute($expression)

    Return SetError(@error, @extended, $result)
EndFunc

#cs
# Get static class property
#
# @param Class|string $this
# @param string $propertyName
# @return mixed
#ce
Func _Class_StaticProperty_Get($this, $propertyName, $line = @ScriptLineNumber)
    If IsMap($this) Then $this = $this['@__ClassName__']

    Local $variableName

    For $i = 1 To 1000
        $variableName = $this&"_"&$propertyName
        If IsDeclared($propertyName) Then Return Eval($variableName)

        $this = __Class_GetParent($this)
        If Null = $this Then Return SetError(1, 0, "Property not found")
    Next

    Return SetError(1, 0, Exception("Maximum recursion reached for property lookup ("&$i&" levels)", 0, Null, $line))
EndFunc

#cs
# Get parent class name
# @param string $className
# @return string|null
#ce
Func __Class_GetParent($className)
    Local $mClass = $__Class_Classes[$className]
    Local $parentClassName = $mClass['Extends']
    If Null = $parentClassName Then Return Null

    Return $parentClassName
EndFunc

Func _Class_instanceof(ByRef $this, $className, $line = @ScriptLineNumber)
    Local $instance = Null
    If IsMap($this) Then
        $instance = $this['@__ClassName__']
    ElseIf IsString($this) Then
        $instance = $this
    Else
        Return False
    EndIf
    
    If Not __Class_Exists($instance) Then Return False

    If Not __Class_Exists($className) Then Return False

    $className = ($__Class_Classes[$className])['ClassName']

    For $i = 1 To 1000
        If $instance = $className Then Return True
        $instance = __Class_GetParent($instance)
        If Null = $instance Then Return False
    Next

    Return SetError(1, 0, Exception("Maximum recursion reached for instanceof ("&$i&" levels)", 0, Null, $line))
EndFunc

Func _Class_GetName(ByRef $this)
    If Not IsMap($this) Then Return SetError(1, 0, Null)

    Return $this['@__ClassName__']
EndFunc

#include "exception.au3"
