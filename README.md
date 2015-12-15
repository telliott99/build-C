I'm going to use this project as a set of notes about how to build and use C libraries on OS X, from the very simplest to more complex and realistic examples.

## Step 1:  Single file

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

## Step 2:  Separate source .c files (3 of them)

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

## Step 3:  Add a header .h file

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

## Step 4:  Pre-built binaries

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

<hr>

Step 5:  Combine `add1.c` and `add2.c` into static library.

```bash
> libtool -static add*.o -o libadd.a
```
To use the library, tell the linker where to find the library, search in the current directory (`-L.`) for a library called `add`, i.e. `libadd.a`.

```bash
> clang -g -Wall -o useadd useadd.c -L. -ladd
> ./useadd
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

<hr>

Step 6:  Combine `add1.c` and `add2.c` into a dynamic library.  To use it we also compile `useadd.c` to an object .o file.

```bash
> clang -c useadd.c
> clang -v useadd.o ./libadd.dylib -o useadd
Apple LLVM version 7.0.2 (clang-700.1.81)
Target: x86_64-apple-darwin15.2.0
Thread model: posix
 "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld" -demangle -dynamic -arch x86_64 -macosx_version_min 10.11.0 -o useadd useadd.o ./libadd.dylib -lSystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/clang/7.0.2/lib/darwin/libclang_rt.osx.a
```
or just
```bash
> clang useadd.o ./libadd.dylib -o useadd
> ./useadd
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

<hr>

Step 7:  Use an OS X framework from the command line:

test2.m
```Objective C
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

Step 8:  Build `add1.c` and `add2.c` into a framework using Xcode.  Use that framework from the command line.  I will just link to the [blog](http://telliott99.blogspot.com/2015/12/swift-using-c-framework.html) for an explanation of how to do this.  Once we have the framework, we can copy it into the build directory and do:

```bash
> clang -g -o useadd -F .  -framework Adder useadd.c
> ./useadd
useadd
f1: 1;  main 2
f2: 10;  main 12
>
```

Alternatively, we can place the framework somewhere like `~/Libary/Frameworks`.  Having done that, we need to tell `clang` where to search:

```bash>
clang -g -o useadd -F ~/Library/Frameworks  -framework Adder useadd.c
> ./useadd
useadd
f1: 1;  main 2
f2: 10;  main 20
>
```

Step 9:  Use the Adder framework from a new Xcode Cocoa app written in Objective-C.  Simply drag the header from a Finder window onto the Xcode General tab under Linked Frameworks and Libraries.

In the AppDelegate, do:
```Objective-C
#import "Adder/Adder.h"
```

This was enough on one trial I did.  But upon repeating all the steps now, it fails... Xcode says it can't find the header.  Fix this by going to Build Settings > Search Paths > Framework Search Paths, and add the path `~/Library/Frameworks` under the app `AdderOC` (not the project).  Now it works.

Add this code to the AppDelegate:

```Objective-C
NSDictionary *eD = [[NSProcessInfo processInfo] environment];
NSLog(@"%@",[[eD objectForKey:@"USER"] description]);
```

Run the app, and the debugger prints:

```
2015-12-15 18:29:18.275 AdderOC[28631:212114] telliott
```
