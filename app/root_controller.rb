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
    @me.drawInRect([[0, 0], @me.size])

    currentContext = UIGraphicsGetCurrentContext()

    CGContextTranslateCTM(currentContext, 0, @me.size.height)
    CGContextScaleCTM(currentContext, 1, -1)

    scale = UIScreen.mainScreen.scale

    if (scale > 1.0)
      CGContextScaleCTM(currentContext, 0.5, 0.5)
    end
    
    features.each_with_index do |feature, index|
      
      # TODO: get some of this out of the loop
      CGContextSetRGBFillColor(currentContext, 0, 0, 0, 0.5)
      CGContextSetStrokeColorWithColor(currentContext, UIColor.whiteColor.CGColor)
      CGContextSetLineWidth(currentContext, 2)
      CGContextAddRect(currentContext, feature.bounds)
      CGContextDrawPath(currentContext, KCGPathFillStroke)

      CGContextSetRGBFillColor(currentContext, 1, 0 , 0, 0.4)

      p "Found Feature!"
      
      if feature.hasLeftEyePosition
        draw_feature(currentContext, atPoint:feature.leftEyePosition)
        p "Left Eye Coord: #{feature.leftEyePosition.x}x#{feature.leftEyePosition.y}"
      end
      if feature.hasRightEyePosition
        draw_feature(currentContext, atPoint:feature.rightEyePosition)
        p "Right Eye Coord: #{feature.rightEyePosition.x}x#{feature.rightEyePosition.y}"
      end
      if feature.hasMouthPosition
        draw_feature(currentContext, atPoint:feature.mouthPosition)
        p "Mouth Coord: #{feature.mouthPosition.x}x#{feature.mouthPosition.y}"
      end
    end

    newView = UIImageView.alloc.initWithFrame([[0, 0], @me.size])
    newView.image = UIGraphicsGetImageFromCurrentImageContext()
    
    newView = UIImageView.alloc.initWithImage(UIGraphicsGetImageFromCurrentImageContext())
    newView.frame = CGRectMake(0, 0, @me.size.width, @me.size.height)
    
    UIGraphicsEndImageContext()


    view.addSubview(newView)
  end

  def draw_feature(context, atPoint:feature_point)
    size = 6
    startx = feature_point.x - (size/2)
    starty = feature_point.y - (size/2)
    CGContextAddRect(context, [[startx, starty], [size, size]])
    CGContextDrawPath(context, KCGPathFillStroke)
  end

end
