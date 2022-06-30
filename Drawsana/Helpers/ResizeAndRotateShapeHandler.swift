import CoreGraphics


class ResizeAndRotateShapeHandler  {
  private var originalTransform: ShapeTransform
    let shape: ShapeSelectable
    var startPoint: CGPoint = .zero

   public init(
    shape: ShapeSelectable
    )
  {
    self.shape = shape
    self.originalTransform = shape.transform
  }
    
    func handleDragStart(context: ToolOperationContext, point: CGPoint) {
      startPoint = point
    }

  private func getResizeAndRotateTransform(point: CGPoint) -> ShapeTransform {
    let originalDelta = startPoint - shape.transform.translation
    let newDelta = point - shape.transform.translation
    let originalDistance = originalDelta.length
    let newDistance = newDelta.length
    let originalAngle = atan2(originalDelta.y, originalDelta.x)
    let newAngle = atan2(newDelta.y, newDelta.x)
    let scaleChange = newDistance / originalDistance
    let angleChange = newAngle - originalAngle
    return originalTransform.scaled(by: scaleChange).rotated(by: angleChange)
  }

  func handleDragContinue(context: ToolOperationContext, point: CGPoint, velocity: CGPoint) {
      var tpshape = shape as? ShapeWithTwoPoints
      if tpshape != nil {
          tpshape?.b = point
      } else {
          shape.transform = getResizeAndRotateTransform(point: point)
      }
  }

 func handleDragEnd(context: ToolOperationContext, point: CGPoint) {
     var tpshape = shape as? ShapeWithTwoPoints
     if tpshape != nil {
         tpshape?.b = point
     } else {
         context.operationStack.apply(operation: ChangeTransformOperation(
           shape: shape,
           transform: getResizeAndRotateTransform(point: point),
           originalTransform: originalTransform))
     }
    
  }

  func handleDragCancel(context: ToolOperationContext, point: CGPoint) {
    shape.transform = originalTransform
    context.toolSettings.isPersistentBufferDirty = true
  }
}
