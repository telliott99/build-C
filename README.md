I'm going to use this project as a set of notes about how to build and use C libraries on OS X, from the very simplest to more complex and realistic examples.

#### Step 1:  Single file

test.c

```C
#include <stdio.h>

int f1(int);

int f1(int x){
    printf( "f1: %d;", x );
    return x+1;
}

int main(int argc, char** argv){
    printf("test:\n");
    printf("  main %d\n", f1(1));
    return 0;
}
```

```bash
> clang -g -Wall test.c -o prog
> ./prog
test:
f1: 1;  main 2
>
```
<hr>

#### Step 2:  Separate source .c files (3 of them)

add1.c

```C
#include <stdio.h>

int f1(int x) {
    printf("f1: %d;", x);
    return x+1;
}
```

add2.c

```C
#include <stdio.h>

int f2(int x) {
  printf("f2: %d;", x);
  return x+10;
}
```

useadd.c

```C
#include <stdio.h>

extern int f1(int);
extern int f2(int);

int main(int argc, char** argv){
    printf("useadd\n");
    printf("  main %d\n", f1(1));
    printf("  main %d\n", f2(10));
    return 0;
}
```

```bash
> clang -g -Wall useadd.c add1.c add2.c -o prog
> ./prog
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

<hr>

#### Step 3:  Add a header .h file

Remove the line "extern" declaration from `useadd.c`, and the build fails.
Add an import for a header file: `#import "add.h"` plus that file:

add.h

```C
int f1(int);
int f2(int);
```

Use the same build command

```
>> clang -g -Wall useadd.c add1.c add2.c -o prog
> ./prog
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

<hr>

#### Step 4:  Pre-built binaries

Use the ``-c`` flag to ``clang``:

```bash
clang -g -Wall -c add*.c
```

Produces `add1.o` and `add2.o`.  Now:

```bash
> clang -g -Wall useadd.c add1.o add2.o -o prog
> ./prog
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

This requires `add.h`:

```bash
> mv add.h tmp
> clang -g -Wall useadd.c add1.o add2.o -o prog
useadd.c:2:10: fatal error: 'add.h' file not found
#include "add.h"
         ^
1 error generated.
>
```

<hr>

#### Step 5:  Combine `add1.c` and `add2.c` into a *static* library.

```bash
> libtool -static add*.o -o libadd.a
```
To use the library, tell the linker where to find the library.  For example, we can search in the current directory (`-L.`) for a library called `-ladd`, which stands for `libadd.a`.

```bash
> clang -g -Wall -o useadd useadd.c -L. -ladd
> ./useadd
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

<hr>

#### Step 6:  Combine `add1.c` and `add2.c` into a *dynamic* library.

```bash
> clang -dynamiclib -current_version 1.0  add*.o  -o libadd.dylib
> clang useadd.c ./libadd.dylib -o useadd
> ./useadd
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

```bash
> otool -L libadd.a
Archive : libadd.a
libadd.a(add1.o):
libadd.a(add2.o):
> otool -L libadd.dylib
libadd.dylib:
	libadd.dylib (compatibility version 0.0.0, current version 1.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1226.10.1)
>
```

To use it we *may* also compile `useadd.c` to an object .o file.

```bash
> clang -c useadd.c
> clang useadd.o ./libadd.dylib -o useadd
> ./useadd
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

<hr>

#### Step 7:  Use an OS X framework from the command line:

test2.m

```objc
#import <Foundation/Foundation.h>
int main (int argc, const char* argv[]) {
    NSDictionary *eD = [[NSProcessInfo processInfo] environment];
    NSLog(@"%@",[[eD objectForKey:@"USER"] description]);
    return 0;
}
```

```bash
> clang -o test test2.m -framework Foundation
> ./test
2015-12-15 18:03:22.185 test[28295:201132] telliott
>
```
<hr>

#### Step 8:  Build `add1.c` and `add2.c` into a framework using Xcode.

Use that framework from the command line.  

I will just link to the [blog](http://telliott99.blogspot.com/2015/12/swift-using-c-framework.html) for an explanation of how to do this.  



Once we have the framework, we can copy it into the build directory and do:

```bash
> clang -g -o useadd -F .  -framework Adder useadd.c
> ./useadd
useadd
f1: 1;  main 2
f2: 10;  main 12
>
```

Before we used `L` to give a search path for libraries, similarly we use `F` to give a search path for frameworks.  

It's better if we can place the framework somewhere like `~/Libary/Frameworks`.  

Having done that, we revise the call to tell `clang` where to search:

```bash>
> clang -g -F ~/Library/Frameworks  -framework Adder useadd.c -o useadd
> ./useadd
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

#### Step 9:  Use the Adder framework from a new Xcode Cocoa app written in Objective-C.  

Make a new Xcode project.

Simply drag the framework from a Finder window onto the Xcode General tab under Linked Frameworks and Libraries.

In the AppDelegate, do:

```objc
#import "Adder/Adder.h"
```

This was enough on one trial I did.  

But upon repeating all the steps now, it fails... Xcode says it can't find the header.  Fix this by going to Build Settings > Search Paths > Framework Search Paths, and add the path `~/Library/Frameworks` under the app `AdderOC` (not the project).

Add Library Search Paths as well (`~/Library/Frameworks/Adder.framework/Headers`).

Now it builds.

Add this code to the AppDelegate:

```objc
int x = f1(1);
printf("AD: %d;", x);
```

The compiler complains that "implicit declaration of function 'f1' is invalid in C99".  But it will still build.  Run the app, and the debugger prints:

```bash
f1: 1;AD: 2;
```

I tried to fix this by addding the file `add.h` to the Adder framework, and following the instructions in `Adder.h`, but it didn't help.

#### Step 10:  Use the Adder framework from a new Xcode Cocoa app written in Swift.

I was able to import `Adder` without any trouble, once I added a bridging header.  

But I was not able to call the function `f1` from Swift.  Embedding the binary into the App didn't help.

#### Step 11:  Import one my Swift frameworks from a swift program executing on the command line.  

Build the framework and control-click on the product and then do show in Finder and drag it to `~/Library/Frameworks`.  Now do

```bash
xcrun swiftc encryptorTest.swift -o prog -F ~/Library/Frameworks -sdk $(xcrun --show-sdk-path --sdk macosx)
```
We do `-F ~/Library/Frameworks` as before, and we also need to tell the linker where the SDK we are building for is located.