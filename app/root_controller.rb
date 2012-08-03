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
    end

    newView = UIImageView.alloc.initWithFrame(view.bounds)
    #newView.contentMode = UIViewContentModeScaleAspectFit
    newView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    view.addSubview(newView)
  end

  def just_rects

    UIGraphicsBeginImageContextWithOptions(@me.size, true, 0)
    @me.drawInRect(view.bounds)

    path = CGPathCreateMutable()

    rectangle1 = CGRectMake(10, 10, 200, 300)

    rectangle2 = CGRectMake(40, 100, 90, 300)

    # Handling the madness of making an array of pointers
    # VERY Procedural, you'll want to clean this up in any ACTUAL practice
    rects_ptr = Pointer.new(CGRect.type, 2) 
    rects_ptr[0] = rectangle1
    rects_ptr[1] = rectangle2

    CGPathAddRects(path, nil, rects_ptr, 2)

    currentContext = UIGraphicsGetCurrentContext()

    CGContextAddPath(currentContext, path)

    UIColor.colorWithRed(0.2, green:0.6, blue:0.8, alpha:1).setFill

    UIColor.blackColor.setStroke

    CGContextSetLineWidth(currentContext, 5)

    CGContextDrawPath(currentContext, KCGPathFillStroke)

    newView = UIImageView.alloc.initWithFrame(view.bounds)
    #newView.contentMode = UIViewContentModeScaleAspectFit
    newView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    view.addSubview(newView)
  end
end
