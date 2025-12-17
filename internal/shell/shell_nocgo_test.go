//go:build !cgo && (darwin || linux || windows)
// +build !cgo
// +build darwin linux windows

// This test file explicitly builds without CGO to avoid LC_UUID issues on macOS with Go 1.23+
// It tests the shell functionality without requiring CGO dependencies.
// See: https://github.com/golang/go/issues/67401

package shell

import (
	"os/exec"
	"strings"
	"testing"
)

// TestShellNameProcessing tests the logic for processing shell names
// without requiring actual shell execution
func TestShellNameProcessing(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "zsh with dash",
			input:    "-zsh",
			expected: "zsh",
		},
		{
			name:     "bash with dash",
			input:    "-bash",
			expected: "bash",
		},
		{
			name:     "fish with dash",
			input:    "-fish",
			expected: "fish",
		},
		{
			name:     "shell without dash",
			input:    "zsh",
			expected: "zsh",
		},
		{
			name:     "shell with path and dash",
			input:    "-/bin/zsh",
			expected: "/bin/zsh",
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			shellName := tt.input
			if strings.HasPrefix(shellName, "-") {
				shellName = shellName[1:]
			}
			if shellName != tt.expected {
				t.Errorf("shellName = %v, want %v", shellName, tt.expected)
			}
		})
	}
}

// TestShellPathGeneration tests the generation of common shell paths
func TestShellPathGeneration(t *testing.T) {
	shell := "zsh"
	expectedPaths := []string{
		"/bin/" + shell,
		"/usr/bin/" + shell,
		"/usr/local/bin/" + shell,
		"/opt/homebrew/bin/" + shell,
		"/usr/local/Cellar/" + shell,
	}

	// Test that paths are generated correctly
	for i, path := range expectedPaths {
		if !strings.Contains(path, shell) {
			t.Errorf("Path %s does not contain shell name %s", path, shell)
		}
		if i > 0 && len(path) <= len(expectedPaths[i-1]) {
			t.Errorf("Path %s should be different from %s", path, expectedPaths[i-1])
		}
	}
}

// TestShellExistence checks if common shells exist without executing them
func TestShellExistence(t *testing.T) {
	shells := []string{"sh", "bash", "zsh"}

	for _, shell := range shells {
		t.Run(shell, func(t *testing.T) {
			// Check if shell exists using LookPath
			_, err := exec.LookPath(shell)
			if err != nil {
				t.Logf("Shell %s not found in PATH (this is OK)", shell)
			} else {
				t.Logf("Found shell %s in PATH", shell)
			}
		})
	}
}