class RootController < UIViewController

  def viewDidLoad
    super

    view.backgroundColor = UIColor.lightGrayColor
    @me = UIImage.imageNamed("gantman.jpeg")
    cme = CIImage.alloc.initWithImage(@me)

    options = NSDictionary.dictionaryWithObject(CIDetectorAccuracyHigh, forKey:CIDetectorAccuracy)
    detector = CIDetector.detectorOfType(CIDetectorTypeFace, context:nil, options:options)

    features = detector.featuresInImage(cme)

    Dispatch::Queue.concurrent.async do
      print_features(features)
    end

    #just_rects
  end

  private
  def print_features features

    UIGraphicsBeginImageContextWithOptions(@me.size, true, 0)
    @me.drawInRect(view.bounds)

    currentContext = UIGraphicsGetCurrentContext()

    #CGContextTranslateCTM(currentContext, 0, view.bounds.size.height)
    #CGContextScaleCTM(currentContext, 1, -1)

    scale = UIScreen.mainScreen.scale

    #if (scale > 1.0)
    #CGContextScaleCTM(currentContext, 0.5, 0.5)
    #end
    
    features.each_with_index do |feature, index|
      
      # TODO: Does this have to be inside the loop?
      CGContextSetRGBFillColor(currentContext, 0, 0, 0, 0.5)
      CGContextSetStrokeColorWithColor(currentContext, UIColor.whiteColor.CGColor)
      CGContextSetLineWidth(currentContext, 2)
      CGContextAddRect(currentContext, feature.bounds)
      CGContextDrawPath(currentContext, KCGPathFillStroke)

      CGContextSetRGBFillColor(currentContext, 1, 0 , 0, 0.4)

      p "Found something"
      p "Left Eye Position = #{feature.leftEyePosition.x}" if feature.hasLeftEyePosition
      p "Right Eye Position = #{feature.rightEyePosition.x}" if feature.hasRightEyePosition
      p "Mouth Position = #{feature.mouthPosition.x}" if feature.hasMouthPosition
      
      if feature.hasRightEyePosition
        drawFeatureInContext(currentContext, atPoint:feature.leftEyePosition)
      end
    end

    newView = UIImageView.alloc.initWithFrame(view.bounds)
    newView.image = UIGraphicsGetImageFromCurrentImageContext()
    
    newView = UIImageView.alloc.initWithImage(UIGraphicsGetImageFromCurrentImageContext())
    newView.frame = CGRectMake(0, 0, 200, 200)
    
    UIGraphicsEndImageContext()


    view.addSubview(newView)
  end

  def drawFeatureInContext(context, atPoint:featurePoint)
    p "Drawing circle"
    radius = 1
    p featurePoint.y
    p featurePoint.y + radius
    #CGContextAddArc(context, featurePoint.x, featurePoint.y, radius, 0, 3.14 * 2, 1)
    CGContextAddRect(context, [[featurePoint.x, featurePoint.x + 1],[featurePoint.y, featurePoint.y + radius]])
    #CGContextAddRect(context, [[5, 6],[100, 110]])
    CGContextDrawPath(context, KCGPathFillStroke)
  end

end
