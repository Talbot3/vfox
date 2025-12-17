# IDE CGO Fix for macOS Go 1.23+

## Problem

When running tests in IDEs (GoLand, VS Code) on macOS with Go 1.23+, you may encounter:

```
dyld[xxxx]: missing LC_UUID load command in /path/to/test_binary
```

This happens because IDEs may ignore build constraints or environment variables.

## Solutions

### Solution 1: Configure IDE Environment Variables

#### For GoLand/IntelliJ IDEA:
1. **Preferences/Settings → Go → Test Environment**
2. Add environment variable: `CGO_ENABLED=0`
3. Apply and restart

#### For VS Code:
1. **Settings → Extensions → Go → Test Environment**
2. Add to `settings.json`:
```json
{
    "go.testEnvVars": {
        "CGO_ENABLED": "0"
    },
    "go.testFlags": ["-v"]
}
```

#### For Vim/Neovim with vim-go:
```vim
let $CGO_ENABLED = "0"
```

### Solution 2: Use Build Constraint Files

Create separate test files with strict build constraints:

```go
//go:build !cgo && (darwin || linux || windows)
// +build !cgo
// +build darwin linux windows

package shell

import "testing"

func TestShellNameProcessing(t *testing.T) {
    // Tests that don't require CGO
}
```

### Solution 3: Project-level Environment File

Create `.env.test` with:
```
CGO_ENABLED=0
```

Then source it before running tests:
```bash
source .env.test
go test ./...
```

### Solution 4: Test Wrapper Script

Create `test.sh`:
```bash
#!/bin/bash
export CGO_ENABLED=0
go test "$@"
```

Run tests with:
```bash
./test.sh ./internal/shell/...
```

### Solution 5: Update GoLand Test Template

In GoLand, you can customize the test template:
1. **File → Settings → Editor → Live Templates → Go**
2. Create new template for test functions
3. Include CGO_ENABLED=0 in the template

## Verification

To verify the fix works:

```bash
# Check that CGO is disabled
go env CGO_ENABLED

# Run tests with verbose output
CGO_ENABLED=0 go test -v ./internal/shell/

# Check binary format (optional)
go test -c -o test_binary ./internal/shell/
file test_binary
```

## If Problems Persist

1. **Restart IDE**: After making changes, restart your IDE
2. **Clear Cache**: Clear GoLand's cache and restart
3. **Check Go Version**: Ensure you're using Go 1.23 or later
4. **Update IDE**: Make sure your IDE is up to date

## Alternative Workaround

If none of the above work, you can:
1. Run tests from command line instead of IDE
2. Downgrade to Go 1.22.x
3. Use Docker for testing

## Related Files

- `internal/shell/shell_test.go` - Original test file with build constraint
- `internal/shell/shell_nocgo_test.go` - Additional CGO-free tests
- `.env.test` - Environment variables for testing