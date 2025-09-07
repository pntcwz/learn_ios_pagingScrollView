//
//  ViewController.swift
//  test25090401
//
//  Created by 黃庭璋 on 2025/9/4.
//

import UIKit

class ViewController: UIViewController {

    // 分頁 ScrollView 與 PageControl
    private let pagingScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPage = 0
        return pc
    }()

    // 使用 UIStackView 簡化水平排列
    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .fill
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let colors: [UIColor] = [.systemRed, .systemGreen, .systemBlue]
    private let realPageCount = 3
    private var didSetInitialOffset = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        pagingScrollView.delegate = self
        setupUI()
        setupPagingContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 只設定一次初始偏移到第一個實際頁面
        guard !didSetInitialOffset, pagingScrollView.frame.width > 0 else { return }
        let w = pagingScrollView.frame.width
        pagingScrollView.setContentOffset(CGPoint(x: w, y: 0), animated: false)
        didSetInitialOffset = true
    }

    private func setupUI() {
        view.addSubview(pagingScrollView)
        pagingScrollView.addSubview(contentStack)
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pagingScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pagingScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingScrollView.heightAnchor.constraint(equalToConstant: 200),

            contentStack.topAnchor.constraint(equalTo: pagingScrollView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: pagingScrollView.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: pagingScrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: pagingScrollView.trailingAnchor),
            contentStack.heightAnchor.constraint(equalTo: pagingScrollView.heightAnchor),

            pageControl.topAnchor.constraint(equalTo: pagingScrollView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        pageControl.numberOfPages = realPageCount
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .darkGray
        pageControl.hidesForSinglePage = false
        view.bringSubviewToFront(pageControl)
    }

    private func setupPagingContent() {
        // 清除可能的舊子視圖
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 產生順序：duplicateLast, page0, page1, ..., pageN-1, duplicateFirst
        for idx in -1...realPageCount {
            let page = makePage(forIndex: idx)
            contentStack.addArrangedSubview(page)
            // 每頁固定等於螢幕寬度
            page.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
        // 更新 pageControl
        pageControl.numberOfPages = realPageCount
        pageControl.currentPage = 0
    }

    private func makePage(forIndex idx: Int) -> UIView {
        let page = UIView()
        page.translatesAutoresizingMaskIntoConstraints = false
        let colorIndex: Int = {
            if idx == -1 { return realPageCount - 1 }
            if idx == realPageCount { return 0 }
            return idx
        }()
        page.backgroundColor = colors[colorIndex]

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.text = "頁面 \(displayIndex(for: idx))"
        page.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: page.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: page.centerYAnchor),
        ])
        return page
    }

    private func displayIndex(for idx: Int) -> Int {
        if idx == -1 { return realPageCount }
        if idx == realPageCount { return 1 }
        return idx + 1
    }

    private func mappedPageIndex(from rawPage: Int) -> Int {
        return ((rawPage - 1) % realPageCount + realPageCount) % realPageCount
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == pagingScrollView, pagingScrollView.frame.width > 0 else { return }
        let w = pagingScrollView.frame.width
        let rawPage = Int((pagingScrollView.contentOffset.x + 0.5 * w) / w)
        pageControl.currentPage = mappedPageIndex(from: rawPage)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == pagingScrollView, pagingScrollView.frame.width > 0 else { return }
        let w = pagingScrollView.frame.width
        let rawPage = Int((pagingScrollView.contentOffset.x + 0.5 * w) / w)
        if rawPage == 0 {
            pagingScrollView.setContentOffset(CGPoint(x: CGFloat(realPageCount) * w, y: 0), animated: false)
        } else if rawPage == realPageCount + 1 {
            pagingScrollView.setContentOffset(CGPoint(x: w, y: 0), animated: false)
        }
    }
}
