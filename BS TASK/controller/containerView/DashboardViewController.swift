//
//  DashboardViewController.swift
//  BS TASK
//
//  Created by Hardik on 11/24/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit

struct ModelContainder : Codable {
    let name : String!
    let img : String!
}

class DashboardViewController: UIViewController {

    @IBOutlet weak var sclView: UIScrollView!
    @IBOutlet weak var clvData: UICollectionView!
    private var ArrayOptions = [ModelContainder]()
    private var selectedTab = 0
    
    let itemcell = "ContainerCollectionViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: itemcell, bundle: nil)
        clvData.register(nib, forCellWithReuseIdentifier: itemcell)
        clvData.delegate = self
        clvData.dataSource = self

        ArrayOptions.append(ModelContainder(name: "Hardik", img: "send"))
        ArrayOptions.append(ModelContainder(name: "Dudhrejiya", img: "recive"))
//        NotificationCenter.default.addObserver(self, selector: #selector(NotificationRecieved), name: NSNotification.Name(rawValue: NOTIFICATIONRECIEVED), object: nil)
     
    }
    
    @objc func NotificationRecieved(){
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
            self.sclView.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
            self.selectedTab = 1
            self.clvData.reloadData()
        }
    }

}

// MARK: - scroll view delegate
extension DashboardViewController: UIScrollViewDelegate
{
    func scrollViewDidEndDecelerating(_ scrollView1: UIScrollView)
    {
        if (scrollView1 == sclView)
        {
            let pageWidth:CGFloat = sclView.frame.width
            let current:CGFloat = floor((sclView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
            let currentPage = Int(current)
            
            selectedTab = currentPage
            
            reloadCollectionView()
        }
    }
    
    func reloadCollectionView()
    {
        self.clvData.reloadData()
        self.clvData.scrollToItem(at:IndexPath(item: selectedTab, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return ArrayOptions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = clvData.dequeueReusableCell(withReuseIdentifier: itemcell, for: indexPath) as! ContainerCollectionViewCell
        cell.viewLine.isHidden = true
        cell.lblTitle.text = ArrayOptions[indexPath.row].name
        cell.imgicon.image = UIImage(named: (ArrayOptions[indexPath.row].img))
        cell.lblTitle.textColor = UIColor.blue
        cell.imgicon.tintColor = UIColor.blue
        if indexPath.item == selectedTab
        {
            cell.lblTitle.textColor = UIColor.black
            cell.imgicon.tintColor = UIColor.black
            cell.viewLine.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if indexPath.item == 0
        {
            self.sclView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        else if indexPath.item == 1
        {
            self.sclView.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
        }
        else if indexPath.item == 2
        {
            self.sclView.setContentOffset(CGPoint(x: self.view.frame.size.width * 2, y: 0), animated: true)
        }
        else
        {
            self.sclView.setContentOffset(CGPoint(x: self.view.frame.size.width * 3, y: 0), animated: true)
        }
        
        selectedTab = indexPath.item
        
        reloadCollectionView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: self.view.frame.width / 2, height: 50)
    }
}



