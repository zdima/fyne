package commands

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
)

type builder struct {
	os, srcdir string
	release    bool
	tags       []string
}

func (b *builder) build() error {
	goos := b.os
	if goos == "" {
		goos = targetOS()
	}

	args := []string{"build"}
	env := append(os.Environ(), "CGO_ENABLED=1") // in case someone is trying to cross-compile...
	if goos == "darwin" {
		// allow user to set target OS version. Both vars must be set by user.
		if !isSet(env, "CGO_CFLAGS") || !isSet(env, "CGO_LDFLAGS") {
			env = append(env, "CGO_CFLAGS=-mmacosx-version-min=10.11", "CGO_LDFLAGS=-mmacosx-version-min=10.11")
		}
	}

	if goos == "windows" {
		if b.release {
			args = append(args, "-ldflags", "-s -w -H=windowsgui")
		} else {
			args = append(args, "-ldflags", "-H=windowsgui")
		}
	} else if b.release {
		args = append(args, "-ldflags", `"-s -w"`)
	}

	// handle build tags
	tags := b.tags
	if b.release {
		tags = append(tags, "release")
	}
	if len(tags) > 0 {
		args = append(args, "-tags", strings.Join(tags, ","))
	}

	cmd := exec.Command("go", args...)
	cmd.Dir = b.srcdir
	if goos != "ios" && goos != "android" {
		env = append(env, "GOOS="+goos)
	}
	cmd.Env = env

	out, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", string(out))
	}
	return err
}

func targetOS() string {
	osEnv, ok := os.LookupEnv("GOOS")
	if ok {
		return osEnv
	}

	return runtime.GOOS
}

func isSet(env []string, s string) bool {
	key := s + "="
	for _, e := range env {
		if strings.HasPrefix(e, key) {
			return true
		}
	}
	return false
}
