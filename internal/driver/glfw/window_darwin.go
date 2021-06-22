package glfw

import (
	"sort"

	"fyne.io/fyne/v2"
)

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Foundation -framework AppKit

#include <AppKit/AppKit.h>

int getWindowIndex(const void* p);
*/
import "C"

func (w *window) WindowIndex() int {
	var ret int = int(C.getWindowIndex(w.viewport.GetCocoaWindow()))
	return ret
}

func sortZOrder(wl []fyne.Window) []fyne.Window {
	sort.Slice(wl, func(i, j int) bool {
		if wi, ok := wl[i].(*window); ok {
			if wj, ok := wl[j].(*window); ok {
				return wi.WindowIndex() < wj.WindowIndex()
			}
		}
		return false
	})
	return wl
}
