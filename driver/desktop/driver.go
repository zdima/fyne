// Package desktop provides desktop specific driver functionality.
package desktop

import "fyne.io/fyne/v2"

// Driver represents the extended capabilities of a desktop driver
type Driver interface {
	// Create a new borderless window that is centered on screen
	CreateSplashWindow() fyne.Window
}

// DragReceiver indicates that a CanvasObject can receive drop from a drag&drop.
// This is used to receive information from the Draggable object.
type DragReceiver interface {
	DragDrop(fyne.Draggable)
}

// DragSource indicates the an object can supply data during drop operation.
type DragSource interface {
	Data() interface{}
}
