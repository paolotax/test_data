class ClasseView < UIView
	
	def drawRect rect
		
		## General Declarations
		context = UIGraphicsGetCurrentContext()

		## Color Declarations
		fillColor = UIColor.colorWithRed(1, green:1, blue:1, alpha:1)
		strokeColor = UIColor.colorWithRed(0, green:0, blue:0, alpha:1)
		color = UIColor.colorWithRed(1, green:0.114, blue:0.114, alpha:0.468)
		color2 = UIColor.colorWithRed(0.41, green:1, blue:0.114, alpha:0.61)
		color3 = UIColor.colorWithRed(1, green:1, blue:0.114, alpha:1)

		## Shadow Declarations
		shadow = strokeColor
		shadowOffset = CGSizeMake(3.1, 3.1)
		shadowBlurRadius = 5

		## Abstracted Attributes
		textContent = "2 A"
		text2Content = "22b"
		text3Content = "Gin Pina Lina"


		## Rounded Rectangle Drawing
		roundedRectanglePath = UIBezierPath.bezierPathWithRoundedRect(CGRectMake(23.5, 20.5, 449, 144), cornerRadius:4)
		CGContextSaveGState(context)
		CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor)
		fillColor.setFill
		roundedRectanglePath.fill
		CGContextRestoreGState(context)

		strokeColor.setStroke
		roundedRectanglePath.lineWidth = 1
		roundedRectanglePath.stroke


		## Bezier Drawing
		bezierPath = UIBezierPath.bezierPath
		bezierPath.moveToPoint(CGPointMake(96.5, 20.5))
		bezierPath.addLineToPoint(CGPointMake(96.5, 161.5))
		strokeColor.setStroke
		bezierPath.lineWidth = 1
		bezierPatternArray = [4, 4, 4, 4]; bezierPattern = Pointer.new(:float, bezierPatternArray.length); bezierPatternArray.each_index{|idx| bezierPattern[idx] = bezierPatternArray[idx] }
		bezierPath.setLineDash bezierPattern, count: 4, phase: 0
		bezierPath.stroke


		## Text Drawing
		textRect = CGRectMake(46, 63, 32, 28)
		strokeColor.setFill
		textContent.drawInRect(textRect, withFont:UIFont.fontWithName("Helvetica-Bold", size:18), lineBreakMode:NSLineBreakByWordWrapping, alignment:NSTextAlignmentCenter)


		## Text 2 Drawing
		text2Rect = CGRectMake(56, 141, 31, 13)
		strokeColor.setFill
		text2Content.drawInRect(text2Rect, withFont:UIFont.fontWithName("Helvetica", size:10), lineBreakMode:NSLineBreakByWordWrapping, alignment:NSTextAlignmentCenter)


		## Bezier 2 Drawing
		bezier2Path = UIBezierPath.bezierPath
		bezier2Path.moveToPoint(CGPointMake(97.5, 109.5))
		bezier2Path.addLineToPoint(CGPointMake(472.5, 109.5))
		CGContextSaveGState(context)
		CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor)
		fillColor.setFill
		bezier2Path.fill
		CGContextRestoreGState(context)

		strokeColor.setStroke
		bezier2Path.lineWidth = 1
		bezier2PatternArray = [4, 4, 4, 4]; bezier2Pattern = Pointer.new(:float, bezier2PatternArray.length); bezier2PatternArray.each_index{|idx| bezier2Pattern[idx] = bezier2PatternArray[idx] }
		bezier2Path.setLineDash bezier2Pattern, count: 4, phase: 0
		bezier2Path.stroke


		## Text 3 Drawing
		text3Rect = CGRectMake(111, 32, 242, 19)
		strokeColor.setFill
		text3Content.drawInRect(text3Rect, withFont:UIFont.fontWithName("Helvetica", size:16), lineBreakMode:NSLineBreakByWordWrapping, alignment:NSTextAlignmentLeft)


		## Oval Drawing
		ovalPath = UIBezierPath.bezierPathWithOvalInRect CGRectMake(293.5, 117.5, 44, 44)
		color.setFill
		ovalPath.fill

		### Oval Inner Shadow
		ovalBorderRect = CGRectInset(ovalPath.bounds, -shadowBlurRadius, -shadowBlurRadius)
		ovalBorderRect = CGRectOffset(ovalBorderRect, -shadowOffset.width, -shadowOffset.height)
		ovalBorderRect = CGRectInset(CGRectUnion(ovalBorderRect, ovalPath.bounds), -1, -1)

		ovalNegativePath = UIBezierPath.bezierPathWithRect(ovalBorderRect)
		ovalNegativePath.appendPath(ovalPath)
		ovalNegativePath.usesEvenOddFillRule = true

		CGContextSaveGState(context)# {
    xOffset = shadowOffset.width + ovalBorderRect.size.width.ceil
    yOffset = shadowOffset.height
    CGContextSetShadowWithColor(context,
        CGSizeMake(xOffset + 0.1, yOffset + 0.1),
        shadowBlurRadius,
        shadow.CGColor)

    ovalPath.addClip
    transform = CGAffineTransformMakeTranslation(-ovalBorderRect.size.width.ceil, 0)
    ovalNegativePath.applyTransform(transform)
    UIColor.grayColor.setFill
    ovalNegativePath.fill# }
		CGContextRestoreGState(context)

		strokeColor.setStroke
		ovalPath.lineWidth = 1
		ovalPath.stroke


		## Oval 3 Drawing
		oval3Path = UIBezierPath.bezierPathWithOvalInRect CGRectMake(414.5, 116.5, 43, 43)
		color3.setFill
		oval3Path.fill

		### Oval 3 Inner Shadow
		oval3BorderRect = CGRectInset(oval3Path.bounds, -shadowBlurRadius, -shadowBlurRadius)
		oval3BorderRect = CGRectOffset(oval3BorderRect, -shadowOffset.width, -shadowOffset.height)
		oval3BorderRect = CGRectInset(CGRectUnion(oval3BorderRect, oval3Path.bounds), -1, -1)

		oval3NegativePath = UIBezierPath.bezierPathWithRect(oval3BorderRect)
		oval3NegativePath.appendPath(oval3Path)
		oval3NegativePath.usesEvenOddFillRule = true

		CGContextSaveGState(context)# {
    xOffset = shadowOffset.width + oval3BorderRect.size.width.ceil
    yOffset = shadowOffset.height
    CGContextSetShadowWithColor(context,
        CGSizeMake(xOffset + 0.1, yOffset + 0.1),
        shadowBlurRadius,
        shadow.CGColor)

    oval3Path.addClip
    transform = CGAffineTransformMakeTranslation(-oval3BorderRect.size.width.ceil, 0)
    oval3NegativePath.applyTransform(transform)
    UIColor.grayColor.setFill
    oval3NegativePath.fill# }
		CGContextRestoreGState(context)

		strokeColor.setStroke
		oval3Path.lineWidth = 1
		oval3Path.stroke


		## Oval 2 Drawing
		oval2Path = UIBezierPath.bezierPathWithOvalInRect CGRectMake(352.5, 116.5, 44, 44)
		color2.setFill
		oval2Path.fill

		### Oval 2 Inner Shadow
		oval2BorderRect = CGRectInset(oval2Path.bounds, -shadowBlurRadius, -shadowBlurRadius)
		oval2BorderRect = CGRectOffset(oval2BorderRect, -shadowOffset.width, -shadowOffset.height)
		oval2BorderRect = CGRectInset(CGRectUnion(oval2BorderRect, oval2Path.bounds), -1, -1)

		oval2NegativePath = UIBezierPath.bezierPathWithRect(oval2BorderRect)
		oval2NegativePath.appendPath(oval2Path)
		oval2NegativePath.usesEvenOddFillRule = true

		CGContextSaveGState(context)# {
		    xOffset = shadowOffset.width + oval2BorderRect.size.width.ceil
		    yOffset = shadowOffset.height
		    CGContextSetShadowWithColor(context,
		        CGSizeMake(xOffset + 0.1, yOffset + 0.1),
		        shadowBlurRadius,
		        shadow.CGColor)

		    oval2Path.addClip
		    transform = CGAffineTransformMakeTranslation(-oval2BorderRect.size.width.ceil, 0)
		    oval2NegativePath.applyTransform(transform)
		    UIColor.grayColor.setFill
		    oval2NegativePath.fill# }
		CGContextRestoreGState(context)

		strokeColor.setStroke
		oval2Path.lineWidth = 1
		oval2Path.stroke


	end
end