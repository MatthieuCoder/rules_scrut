# rules_scrut

This is a bazel module that can be used to generate scrut test cases,
aggregate them (merge) in a single .t file, and execute them while
depending on bazel build artifacts.

## Scrut test file generation

A simple scrut test case can be generated from
a bazel rule like so:

```bazel
scrut_case(
    name = "addition",
    description = "Check that 1 + 1 is 2",
    command = "echo $(( 1 + 1 ))",
    output = "2",
    return_code = 0,
)
```

Generates:

```scrut
Check that 1 + 1 is 2
  $ echo $(( 1 + 1 ))
  2
```

## Running scrut tests

A scrut test file can be tested like so:

```bazel
scrut_test(
    name = "addition_test",
    src = ":addition",
    data = [],
)
```

Like so, our addition test will get exectued
when doing `bazel test` on it.

## Aggregating scrut tests

Bazel test targets tend to be pretty grannular,
and in most cases, aggregating scrut_case into 
a single case could be useful.

Aggregating those tests can be done like so:

```bazel
scrut_aggregate(
    name = "cases",
    srcs = [
        ":case1",
        ":case2"
    ],
)
```

## Emitting scrut files in the source tree

A rule is provided to automatically copy .t files
into your source tree, 

```bazel
scrut_emit(
    name = "emit_tests",
    srcs = [":addition"],
    dst_dir = "test/generated",
)
```

This action needs to be executed manually like so:

```shell
 bazel run //:emit_tests
```
