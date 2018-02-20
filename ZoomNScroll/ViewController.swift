//
//  ViewController.swift
//  ISpy
//
//  Created by Dennis Lau on 2017-11-26.
//  Copyright © 2017 Dennis Lau. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet var doubleTapGesture: UITapGestureRecognizer!
	
	var imageSize: CGSize! {
		return imageView.image?.size
	}
	var initScale: CGFloat!
	var currentScale: CGFloat {
		get {
			return scrollView.zoomScale
		}
		set(scale) {
			scrollView.setZoomScale(scale, animated: true)
		}
	}
	var fillScale: CGFloat {
		let widthScale = view.frame.width / imageView.bounds.width
		let heightScale = view.frame.height / imageView.bounds.height
		let scale = max(widthScale, heightScale)
		return scale
	}
	var isInPortrait: Bool {
		return view.frame.height > view.frame.width
	}
	var isZoomed: Bool = false
	
	// rotation support setup
	override var shouldAutorotate: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.allButUpsideDown
	}
	
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return UIInterfaceOrientation.portrait
	}
	
	// zooming support setup
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		imageView.image =
		scrollView.delegate = self
		// set VC instance as the delegate of scrollView
		scrollView.alwaysBounceHorizontal = true
		scrollView.contentInsetAdjustmentBehavior = .never
		// stop system from setting up safe area that affects scrollView zoom in landscape
		
		// This is used to force update the imageView frame to match image size
		if let imageSize = imageView.image?.size {
			imageView.frame.size = imageSize
		}
		print("image width: \(imageView.frame.width), image height: \(imageView.frame.height)")
		initZoomScale(view.frame.size, animated: false)
	}
	
	override func viewDidLayoutSubviews() {
		// This is the trick. Gets called everytime orientation changes to set inset.
		super.viewDidLayoutSubviews()
		// return to default zoom when rotated if imageView smaller than frame
		if view.frame.width >= imageView.frame.width &&
			view.frame.height >= imageView.frame.height {
			resetImageScale()
		} else {
			imageView.bounds.size = imageSize
			setScrollViewInset()
			view.layoutIfNeeded()
		}
	}

	func resetImageScale() {
		// if image is not scaled correctly, try resetting bounds
		imageView.bounds.size = imageSize
		initZoomScale(view.frame.size, animated: false)
		setScrollViewInset()
		view.layoutIfNeeded()
	}
	
	func initZoomScale(_ size: CGSize, animated: Bool) {
		let scale = getMinScale(for: size)
		scrollView.minimumZoomScale = scale
		scrollView.setZoomScale(scale, animated: animated)
		initScale = scale
		setScrollViewInset()
	}
	
	func getMinScale(for size: CGSize) -> CGFloat {
		//		divide screen size by image size
		let widthScale = size.width / imageView.bounds.width
		let heightScale = size.height / imageView.bounds.height
		//		get min of two so entire image will show
		let scale = min(widthScale, heightScale)
		return scale
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		print("currentScale: \(currentScale)")
		setScrollViewInset()
	}
	
	func setScrollViewInset() {
		// make content center when smaller than scroll view
		
		let offsetX = max((scrollView.frame.width - scrollView.contentSize.width) * 0.5, 0)
		let offsetY = max((scrollView.frame.height - scrollView.contentSize.height) * 0.5, 0)
		scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
	}
	
	@IBAction func doubleTappedGesture(_ sender: Any) {
		
		// block off zoom for images that are init at scale > 1
		guard imageSize.height >= view.frame.height || imageSize.width >= view.frame.width else { return }
		
		// remember to use view tap location, as scrollView can give negative numbers
		let viewTapLocation = doubleTapGesture.location(in: view)
		print("isZoomed: \(isZoomed)")
		
		switch (currentScale - fillScale) {
		case 0:
			print("isInPortrait: \(isInPortrait)")
			print("view.frame.height: \(view.frame.height)")
			print("view.bounds.height: \(view.bounds.height)")
			print("viewTapLocation.y: \(viewTapLocation.y)")
			print("scrollView.contentSize.height: \(scrollView.contentSize.height)")
			print("imageView.frame.height: \(imageView.frame.height)")
			print("imageView.bounds.height: \(imageView.bounds.height)")
			print("imageSize.height: \(imageSize.height)")
			
			// currently at fill scale, run deep zoom code
			guard imageSize.width > view.frame.width ||
				imageSize.height > view.frame.width
				else { fallthrough }
			
			// contentOffset: imaging a phone on a large piece of paper; distance from upper left corner of paper to upper left corner of phone using the paper as scale, at the current zoom level
			// brings x y (image 1:1 pixel size coordinate, top left 0,0) to center of phone
			// width and height: put how many pixels into the width or height of device?
			
			// WARNING on scroll view frame: scroll view zooms by applying a scaling transform to the scalable view; do not rely on the frame of a scroll view when doing calculations on transformation
			
			scrollView.zoom(to: CGRect(x: (scrollView.contentOffset.x + viewTapLocation.x) / currentScale, y: ( (scrollView.contentOffset.y + viewTapLocation.y) / currentScale ) - ( view.frame.height / 2 ), width: 0, height: view.frame.height), animated: true)
			
			isZoomed = true

		case -CGFloat.infinity..<0:
			// currentScale < fillScale, run fill screen code
			
			guard isZoomed == false else { fallthrough }
			
			print("imageSize: \(imageSize)")
			print(view.frame)

			guard imageSize.height >= view.frame.height && imageSize.width >= view.frame.width else {
				
				// when image size is smaller than screen resolution on the filling axis, set scale 1
				
				scrollView.zoom(to: CGRect(x: (scrollView.contentOffset.x + viewTapLocation.x) / currentScale, y: ( (scrollView.contentOffset.y + viewTapLocation.y) / currentScale ) - ( view.frame.height / 2 ), width: 0, height: view.frame.height), animated: true)
				
				isZoomed = true
				
				break
			}
			
			if isInPortrait {
				if imageView.frame.height < view.frame.height {
					// fill vertically
					scrollView.zoom(to: CGRect(x: viewTapLocation.x / currentScale, y: viewTapLocation.y / currentScale, width: 0, height: imageSize.height), animated: true)
				} else if imageView.frame.width < view.frame.width {
					// fill horizontally for weird pics
					scrollView.zoom(to: CGRect(x: viewTapLocation.x / currentScale, y: viewTapLocation.y / currentScale, width: imageSize.width, height: 0), animated: true)
				}
			} else if !isInPortrait {
				if imageView.frame.width < view.frame.width {
					// fill horizontally
					scrollView.zoom(to: CGRect(x: viewTapLocation.x / currentScale, y: viewTapLocation.y / currentScale, width: imageSize.width, height: 0), animated: true)
				} else if imageView.frame.height < view.frame.height {
					// fill vertically for pano
					scrollView.zoom(to: CGRect(x: viewTapLocation.x / currentScale, y: viewTapLocation.y / currentScale, width: 0, height: imageSize.height), animated: true)
				}
			}
			
			isZoomed = true
			
		default:
			
			guard isZoomed == true else { break }
			
			initZoomScale(view.frame.size, animated: true)
			
			isZoomed = false
		}
	}
	
	// Additional config when changing orientation
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		// code before transition
		
		// return to default zoom when rotated if imageView smaller than frame
		if view.frame.width >= imageView.frame.width &&
			view.frame.height >= imageView.frame.height {
			initZoomScale(size, animated: true)
		} else {
			// only set min scale when imageView is larger than frame
			let scale = getMinScale(for: size)
			scrollView.minimumZoomScale = scale
		}
		
		var canCurrentScaleFill: Bool {
			// note that fillScale here is calculated using the new orientation
			//	otherwise use "let isScaleGreaterThanFill: Bool = currentScale > fillScale"
			return currentScale >= fillScale
		}
		print("canCurrentScaleFill: \(canCurrentScaleFill)")
		
		let oldOffsetX = scrollView.contentOffset.x
		let oldOffsetY = scrollView.contentOffset.y
		let oldViewFrameWidth = view.frame.width
		let oldViewFrameHeight = view.frame.height
		
		coordinator.animate(alongsideTransition: { (vcTransitionCoordinateContext) in

			// during rotation
			// view.frame has already been rotated

			// maintain same view center point after rotation
			
//			should not have to guard anymore with the !isScaleGreaterThanFill logic
//			guard isScaleGreaterThanFill else {return}
			
			let newTargetOffsetX = oldOffsetX + ( oldViewFrameWidth - self.view.frame.width ) / 2
			let newTargetOffsetY = oldOffsetY + ( oldViewFrameHeight - self.view.frame.height ) / 2
			// have to calculate max offset, otherwise offset too much and there will be a black edge on the right / at the bottom
			let maxOffsetX = self.imageSize.width * self.currentScale - self.view.frame.width
			let maxOffsetY = self.imageSize.height * self.currentScale - self.view.frame.height
			
			var setX: CGFloat
			var setY: CGFloat
			
			if canCurrentScaleFill {
				if newTargetOffsetX < 0 {
					setX = 0
				} else if newTargetOffsetX > maxOffsetX {
					setX = maxOffsetX
				} else {
					setX = newTargetOffsetX
				}
				
				if newTargetOffsetY < 0 {
					setY = 0
				} else if newTargetOffsetY > maxOffsetY {
					setY = maxOffsetY
				} else {
					setY = newTargetOffsetY
				}
			} else {
				// we have to allow these values to be negative for inset to work somehow
				setX = maxOffsetX / 2
				setY = maxOffsetY / 2
			}
			
			let newOffsetPoint = CGPoint(x: setX, y: setY)
			self.scrollView.setContentOffset(newOffsetPoint, animated: true)
		}) { (vcTransitionCoordinateContext) in
			// after rotation
		}
	}

	// DEBUG
	
	@IBAction func singleTappedGesture(_ sender: Any) {
//		switch imageView.image {
//		case #imageLiteral(resourceName: "TestPic01")?:
//			imageView.image = #imageLiteral(resourceName: "TestPic02")
//		case #imageLiteral(resourceName: "TestPic02")?:
//			imageView.image = #imageLiteral(resourceName: "TestPic03")
//		default:
//			imageView.image? = #imageLiteral(resourceName: "TestPic01")
//		}
//		initZoomScale(view.frame.size, animated: false)
//		print(imageView.bounds.width)
//		setScrollViewInset()
//		view.layoutIfNeeded()
	}
	
	//	func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
	//		print("currentScale: \(currentScale)")
	//	}
	//
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			print("contentOffset: \(scrollView.contentOffset)")
			print("currentScale: \(currentScale)")
			print("fillScale: \(fillScale)")
		}
}
