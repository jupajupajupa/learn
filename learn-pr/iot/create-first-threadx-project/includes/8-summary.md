## Introduction

We discussed several important terms and concepts in this module, as they're related to Azure ThreadX RTOS. Following are brief definitions of some key points.

### Thread

A thread is a semi-independent program segment; threads share the same memory space within a program. The terms "task" and "thread" are sometimes used interchangeably. However, we use the term `thread` because it's more descriptive and more accurately reflects the processing that occurs.

### ThreadX building blocks

A somewhat arbitrary classification of a ThreadX project, intended to clarify the discussion of various parts of a project.

- Building block 1 contains #includes, defines, and declarations
- Building block 2 contain the main entry point
- Building block 3 contains Application Define, which is where resources are typically created
- Building block 4 contains entry functions for threads, application timers, and notifications

### GitHub Codespaces

[GitHub Codespaces](https://docs.github.com/en/codespaces) uses VMs that created in the cloud to enable the Visual Studio Code running on the desktop or web that can use these VMs as your building environment. We use GitHub Codespaces to build and run our ThreadX projects.

### Visual Studio

An integrated development environment (IDE) from Microsoft. It's used to develop computer programs, and websites, web apps, web services, and mobile apps. We use Visual Studio to build and debug our ThreadX projects.
