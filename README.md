# dd-star

## What is dd-star?

`dd-star` is a template providing some building infrastructure for C++ projects
that are structured like a star: a `core` project creating libraries and tools
used by all the `satellite` projects to build further libraries and programs.

## Who develops dd-star?

`dd-star` is being developed by me, Dario Domizioli. I have used it for a few
of my C++ projects and I thought I'd share it with the world in case it could be
useful to other people.

## Why use dd-star?

Most C++ projects are quite complex, and accordingly require a complex build
system, especially if they are intended to be multi-platform. There is a large
number of building tools available as either free / open software or commercial
software, and `dd-star` does not try to compete with those.

`dd-star` is just a template that focuses on one particular use case, which
happens to be the one I often use for my projects. It is designed specifically
for that use case, it has minimal dependencies, and it supports UNIX systems.

`dd-star` does not try to be a solution for everything or everyone. If your use
case is similar to mine, you'll hopefully find `dd-star` very useful. If not,
there is no reason why `dd-star` should appeal to you.

## What are the features of dd-star?

* Licensed under the permissive Apache 2.0 License.
* Supports Linux and MacOSX.
* Minimal external dependencies: just `make`, `python`, `git` and a compiler.
* GNU Make-based build system.
* Minimal effort required to write project Makefiles (a few boilerplate lines).
* Auto-discovery of source files, headers, unit tests and system tests.
* Baked-in support for CATCH-based unit tests.
* Baked-in support for system tests.
* Baked-in support for Doxygen-based documentation, if `doxygen` is available.
* Packages the final product in a standard directory structure.

## What are the requirements of dd-star?

### Operating System

* Linux or MacOSX

Technically, I think any UNIX-like system is suitable as an operating system in
which to use `dd-star`. However, I have only tested Linux (Ubuntu and SuSE) and
MacOSX 10.

### Compiler

* GCC 4.8 (or later), or Clang 3.4 (or later)
* A C++ standard library that supports the C++11 standard

The build system will prefer Clang if both compilers are available. If none is
found, it will use whatever is defined in $CC, $CXX and $LD, however these might
not be compatible with the Clang or GCC flags.

### Tools

* GNU Make 3.81 or later
* Python 2.7
* Git
* [optional] Doxygen 1.8.x or later, for generating documentation

I think Python 3.x should be OK too, but I have not tested it.

### ... and that's it.

## How to work with a dd-star based project.

You can start from a clone of `dd-star`. Go to that directory and type `make`.
A help message will explain which targets are available for handling the default
projects.

`make everything` will always build all projects (`core` and `satellites`).

`make reset` will clean all projects.

You can then just start playing with it, adding projects and files. It's that
simple.

Full guidance for working with `dd-star` is provided in GUIDE.md.
