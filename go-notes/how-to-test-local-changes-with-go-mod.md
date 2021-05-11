# How to Test Local Changes with Go Mod

We are developing on two different Go projects using modules:

* A `github.com/acme/bar` module
* Another `github.com/acme/foo` module that depends on the first one    

Let’s say we made some changes to `github.com/acme/bar` and we would like to test the impacts on `github.com/acme/foo` before committing them.

Without Go modules, it was pretty straightforward as our changes were done in `GOPATH` so they were automatically reflected.

With Go modules, the trick is to replace our import by the `physical location` of the project:

```text
module github.com/acme/foo

go 1.12

require (
    github.com/acme/bar v1.0.0
)

replace github.com/acme/bar => /path/to/local/bar
```

Here, `/path/to/local/bar` is the actual location of the `bar` project containing the local changes.

We can also use the following command:

`go mod edit -replace github.com/acme/bar=/path/to/local/bar`

