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
		imageView.image = #imageLiteral(resourceName: "iphoneResolution")
		scrollView.delegate = self
		// set VC instance as the delegate of scrollView
		scrollView.alwaysBounceHorizontal = true
		scrollView.contentInsetAdjustmentBehavior = .never
		// stop system from setting up safe area affects scrollView zoom in landscape
		
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
		setScrollViewInset()
		view.layoutIfNeeded()
	}

	func initZoomScale(_ size: CGSize, animated: Bool) {
		let scale = getMinScale(for: size)
		scrollView.minimumZoomScale = scale
		scrollView.setZoomScale(scale, animated: animated)
		initScale = scale
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
		setScrollViewInset()
	}
	
	func setScrollViewInset() {
		// make content center when smaller than scroll view
		
		let offsetX = max((scrollView.frame.width - scrollView.contentSize.width) * 0.5, 0)
		let offsetY = max((scrollView.frame.height - scrollView.contentSize.height) * 0.5, 0)
		scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
	}
	
	@IBAction func doubleTappedGesture(_ sender: Any) {
		// remember to use view tap location, as scrollView can give negative numbers
		let viewTapLocation = doubleTapGesture.location(in: view)

		if currentScale < fillScale {
			if isInPortrait {
				scrollView.zoom(to: CGRect(x: imageSize.width * viewTapLocation.x / view.frame.width, y: imageSize.height * viewTapLocation.y / view.frame.height, width: 0, height: imageSize.height), animated: true)
			} else if !isInPortrait {
				scrollView.zoom(to: CGRect(x: imageSize.width * viewTapLocation.x / view.frame.width, y: imageSize.height * viewTapLocation.y / view.frame.height, width: imageSize.width, height: 0), animated: true)
			}
		} else {
			initZoomScale(view.frame.size, animated: true)
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
		
		coordinator.animate(alongsideTransition: { (vcTransitionCoordinateContext) in

			// during rotation
		
		}) { (vcTransitionCoordinateContext) in
	
			// after rotation

		}
	}
}
