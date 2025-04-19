#include "src/class.au3"

; -----------------------------
; Animal Class
; -----------------------------
_Class_Register("Animal", "Animal_Constructor")

Func Animal_Constructor(ByRef $this, $name)
    $this.name = $name
EndFunc

Func Animal_getName(ByRef $this)
    Return $this.name
EndFunc

Func Animal_makeSound(ByRef $this)
    Return "Generic animal sound"
EndFunc

Func Animal_static_getSpecies($static)
    Return "Unknown species"
EndFunc

; -----------------------------
; Dog Class (inherits Animal)
; -----------------------------
_Class_Register("Dog", "Dog_Constructor", "Animal")

Func Dog_Constructor(ByRef $this, $name, $breed)
    _Class_Parent_Constructor_Call($this, $name)

    $this.breed = $breed
    ConsoleWrite("Dog constructor called for: " & $this.name & " (Breed: " & $this.breed & ")" & @CRLF)
EndFunc

Func Dog_getBreed(ByRef $this)
    Return $this.breed
EndFunc

Func Dog_makeSound(ByRef $this)
    Return "Woof!"
EndFunc

Func Dog_static_getSpecies($static)
    Return "Canine"
EndFunc

; -----------------------------
; Usage
; -----------------------------
$animal = _Class_New("Animal", "Generic Animal")
ConsoleWrite(_Class_Method_Call($animal, "getName") & " says: " & _Class_Method_Call($animal, "makeSound") & @CRLF)
ConsoleWrite("Species: " & _Class_StaticMethod_Call("Animal", "getSpecies") & @CRLF)

ConsoleWrite(@CRLF)

$dog = _Class_New("Dog", "Buddy", "Golden Retriever")
ConsoleWrite(_Class_Method_Call($dog, "getName") & " is a " & _Class_Method_Call($dog, "getBreed") & " and says: " & _Class_Method_Call($dog, "makeSound") & @CRLF)
ConsoleWrite("Species: " & _Class_StaticMethod_Call("Dog", "getSpecies") & @CRLF)

ConsoleWrite(@CRLF)

; -----------------------------
; Error / Exception Example
; -----------------------------
_Class_Register("Test")

Func Test_test(ByRef $this)
    Return SetError(3, 2, 1)
EndFunc

Func Test_static_test($static)
    Return SetError(123, 321, "return value")
EndFunc

$test = _Class_New("Test")
$result = _Class_Method_Call($test, "test")
ConsoleWrite("Instance Method Call Result:" & @CRLF)
ConsoleWrite("@error: " & @error & @CRLF)
ConsoleWrite("@extended: " & @extended & @CRLF)
ConsoleWrite("(" & VarGetType($result) & ") " & $result & @CRLF)

ConsoleWrite(@CRLF)

$result = _Class_StaticMethod_Call("Test", "test")
ConsoleWrite("Static Method Call Result:" & @CRLF)
ConsoleWrite("@error: " & @error & @CRLF)
ConsoleWrite("@extended: " & @extended & @CRLF)
ConsoleWrite("(" & VarGetType($result) & ") " & $result & @CRLF)

ConsoleWrite(@CRLF)

$result = _Class_StaticMethod_Call("Test", "test2") ; nonexistent method
ConsoleWrite("Invalid Static Method Call Result:" & @CRLF)
ConsoleWrite("@error: " & @error & @CRLF)
ConsoleWrite("@extended: " & @extended & @CRLF)

If @error <> 0 And _Class_instanceof($result, "__Exception") Then
    ConsoleWrite(_Class_Method_Call($result, "ToString") & @CRLF)
Else
    ConsoleWrite("(" & VarGetType($result) & ") " & $result & @CRLF)
EndIf
