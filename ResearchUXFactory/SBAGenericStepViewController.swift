//
//  SBAGenericStepViewController.swift
//  ResearchUXFactory
//
//  Created by Josh Bruhin on 5/16/17.
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


import UIKit

/**
 SBAGenericStepViewController: A custom instance of ORKStepViewController. Its subviews include a UITableView,
 an SBAStepNavigationView, which may or may not be 'embedded' in the tableView as its footerView, and
 an SBAStepHeaderView, which is 'embedded' in the tableView as its headerView.
 
 This class populates the contents and properties of the headerView and navigationView based on ORKStep, which is
 supplied upon init(). This is done in setupViews(), which is also where the tableView is created.
 
 An instance of SBAGenericStepDataSource is created upon init() and is the UITableViewDataSource. It's based on
 ORKStep and is assigned to property tableData. The tableData also keeps track of answers that are derived
 from the user's input and it provides the ORKResult to our delegate.
 
 This class is responsible for acquiring input from the user, validating it, and supplying it as an answer to
 to the model (tableData). This is typically done in delegate call backs from various input views, such as
 UITableView (didSelectRow) or UITextField (valueDidChange or shouldChangeCharactersInRange).
 
 Some ORKSteps, such as ORKInstructionStep, require no user input (and have no ORKFormItems). These steps
 will result in tableData that has no sections and, therefore, no rows. So the tableView will simply have a
 headerView, no rows, and a footerView.
 
 To customize the view elements, subclasses should override the initializeViews() method. This will allow
 the use of any custom element (of the appropriate type) to be used instead of the default instances. To just
 customize the appearance or properties of the headerView and navigationView, subclasses can simply override
 setupHeaderView() and setupNavigationView().
 */


open class SBAGenericStepViewController: ORKStepViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SBAGenericStepDataSourceDelegate {
    
    private let kMainViewBottomMargin: CGFloat = 30.0
    private let kDefaultRowHeight: CGFloat = 75.0
    private let kFormStepMinHeaderHeight: CGFloat = 180
    
    private var navigationViewHeight: CGFloat = 0.0
    private var savedVerticalScrollOffet: CGFloat = 0.0
    private let useStickyNavView = SBAGenericStepUIConfig.shouldUseStickyNavigationView()
    
    private let kEstimatedRowHeight: CGFloat = 100

    open var tableData: SBAGenericStepDataSource?
    open var tableView: UITableView?
    open var headerView: SBAStepHeaderView?
    open var navigationView: SBAStepNavigationView?
    
    // we keep a copy of the original result after initialization so we can return that if the user
    // does not continue to the next step instead of returning any answers they might have given before
    // closing or cancelling
    
    var originalResult: ORKStepResult!
    var userHasContinued = false
    
    
    var tableViewInsetBottom: CGFloat {
        get {
            return useStickyNavView ? navigationViewHeight + constants().mainViewBottomMargin : constants().mainViewBottomMargin
        }
    }
    
    lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = Int(NSDecimalNoScale)
        formatter.usesGroupingSeparator = true
        return formatter;
    }()
    
    
    /**
     Index of this step in the current flow. Will cause the progressView in the headerView to be updated
     */
    public var stepIndex: Int = 0 {
        didSet {
            headerView?.progressView.currentStep = stepIndex
        }
    }
    
    /**
     Total number of steps in the current flow. Will cause the progressView in the headerView to be updated
     */
    public var stepCount: Int = 0 {
        didSet {
            headerView?.progressView.totalSteps = stepCount
        }
    }
    
    
    // Override result so we can generate our own result from our internal model
    override open var result: ORKStepResult? {
        get { return customResult() }
    }
    
    
    // MARK: Initializers
    
    override public init(step: ORKStep, result: ORKResult?) {
        super.init(step: step)
        commonInit(with: result)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(with: nil)
    }
    
    func commonInit(with result: ORKResult?) {
        setupModel(with: result)
    }
    
    
    // MARK: View lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // show or hide our navigation bar
        navigationController?.setNavigationBarHidden(!shouldShowNavigationBar(), animated: false)
        
        setupViews()
    }
        
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        // Dismiss all textField's keyboard
        tableView?.endEditing(false)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // need to do this here because when the navView is generated, our delegate has not yet been set
        // so we don't know answers on whether or not there are previous or next steps
        
        navigationView?.nextButton.isHidden = !hasNextStep()
        navigationView?.previousButton.isHidden = !hasPreviousStep()
        
        // update enabled state of next button
        navigationView?.nextButton.isEnabled = shouldEnableNextButton()
        
        // setup nav bar because this is where super does it and we need to override
        setupNavBar()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // if we have no tableView or navigationView, then nothing to do
        guard let tableView = tableView, let navigationView = navigationView else {
            return
        }
        
        // need to save height of our nav view so it can be used to calculate the bottom inset (margin)
        navigationViewHeight = navigationView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        let totalHeight = tableView.contentSize.height + navigationViewHeight
        let contentSizeExceedsTableHeight = totalHeight > tableView.frame.size.height
        
        if !useStickyNavView && contentSizeExceedsTableHeight {
            
            // put the navView in the tableView as it's footerView
            // we need to add the view as the footer view, get it's height, reset the views frame,
            // then add as the table's footerView again. This is because the view height is dynamic
            // and the tableView won't adjust it's height dynamically otherwise
            
            navigationView.translatesAutoresizingMaskIntoConstraints = true
            tableView.tableFooterView = navigationView
            navigationView.frame = CGRect(x: 0, y: 0, width: navigationView.frame.size.width, height: navigationViewHeight)
            tableView.tableFooterView = navigationView
        }
        else {
            
            // pin navView to bottom of screen
            navigationView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(navigationView)
            navigationView.alignToSuperview([.leading, .trailing, .bottom], padding: 0.0)
            
            // we also need to add an invisible view as the table's footerview so we don't get
            // a bunch of empty rows
            
            let footerView = UIView()
            footerView.backgroundColor = UIColor.clear
            tableView.tableFooterView = footerView
            
            // show the shadow only if our content size is big enough for content to underlap the shadow
            navigationView.shouldShowShadow = contentSizeExceedsTableHeight
        }
        
        // set the tableView bottom inset
        var inset = tableView.contentInset
        inset.bottom = tableViewInsetBottom
        tableView.contentInset = inset
    }
    
    // MARK: Model setup
    
    /**
     Creates and assigns a new instance of our model, SBAGenericStepDataSource.
     @param   result   The result that is provided upon init()
     */
    open func setupModel(with result: ORKResult?) {
        tableData = SBAGenericStepDataSource(step: step, result: result)
        tableData?.delegate = self
        
        // we save our current result so we can return it if the user does not continue
        // to the next step. If they do continue to the next step, then we get a new result
        // from our model. This is done in customResult()
        
        originalResult = tableData?.results(parentResult: super.result!)
    }
    
    /**
     Get updated results from our model, adding to the current result from super, or returns
     our originalResult if the user has not continued to the next step.
     @return    The latest ORKStepResult
     */
    open func customResult() -> ORKStepResult! {
        return userHasContinued ? tableData!.results(parentResult: super.result!) : originalResult
    }
    
    
    // MARK: View setup
    
    // override super's stepDidChange. We don't want to call super here because this is where
    // all of it's view elements are setup, which we aren't using.
    func customStepDidChange() {
        // nothing
    }
    
    /**
     Create all the view elements. Subclasses can override to provide custom instances. A customView
     can optionally be created here by the subclass.
     */
    open func initializeViews() {
        headerView = SBAStepHeaderView()
        navigationView = SBAStepNavigationView()
    }
    
    open func setupNavBar() {
        
        // setup back button
        let showBackButton = SBAGenericStepUIConfig.backButtonPosition() == .navigationBar
        if !showBackButton {
            
            // if we are being displayed in a page view controller, then we will not be able to remove
            // our back button becuase it is set at the page VC level. So we test our delegate to see
            // if it is a page VC and, if it is, we get a reference to it and remove the back button
            
            if let pageViewController = self.delegate as? SBAGenericPageStepViewController {
                pageViewController.navigationItem.leftBarButtonItem = nil
            } else {
                navigationItem.leftBarButtonItem = nil
            }
        } else {
            // super provides a back button when needed, so we just use it
        }
    }
    
    open func setupViews() {
        
        initializeViews()
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.sectionHeaderHeight = 0.0
        tableView?.estimatedRowHeight = constants().defaultRowHeight
        tableView?.estimatedSectionHeaderHeight = 0.0
        tableView?.separatorStyle = .none
        
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = kEstimatedRowHeight

        view.addSubview(tableView!)
        
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.alignAllToSuperview(padding: 0.0)
        
        // setup our header view
        setupHeaderView(headerView!)
        
        // to get the tableView to size the headerView properly, we have to get the headerView height
        // and manually set the frame with that height
        
        let headerHeight = headerView!.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        headerView?.frame = CGRect(x: 0, y: 0, width: headerView!.frame.size.width, height: headerHeight)
        tableView?.tableHeaderView = headerView
                
        // setup the navigationView. we don't add it to the view yet because it may have to
        // be placed as the tableView's footerView or it may be added to the main view and pinned
        // to the bottom. This depends on the eventual frame size of the tableView, so we need to
        // wait until viewDidLayoutSubviews() so we know what the height will be
        
        setupNavigationView(navigationView)
    }
    
    /**
     Auto layout constraint constants for the margin used at the bottom of the main view
     and the default tableView row height.
     @return    A struct with the layout constants
     */
    open func constants() -> (mainViewBottomMargin: CGFloat, defaultRowHeight: CGFloat, formStepMinHeaderHeight: CGFloat) {
        
        // we only need some bottom margin if we have any table data (rows), otherwise, the bottom
        // margin built into the headerView is enough
        
        return (tableView!.numberOfSections > 0 ? kMainViewBottomMargin : 0.0,
                kDefaultRowHeight,
                kFormStepMinHeaderHeight)
    }
    
    /**
     Specifies whether the navigation bar should be shown.
     @return    A Bool indicating if next navigation bar should be shown
     */
    open func shouldShowNavigationBar() -> Bool {
        return true
    }
    
    /**
     Specifies whether the next button should be enabled based on the validity of the answers for
     all form items. If tableData is nil, then false is returned.
     
     @return    A Bool indicating if next button should be enabled
     */
    open func shouldEnableNextButton() -> Bool {
        guard let tableData = tableData else { return false }
        return tableData.allAnswersValid()
    }
    
    /**
     Specifies whether the learn more button should be shown.
     @return    A Bool indicating if button should be shown
     */
    open func shouldShowLearnMore() -> Bool {
        
        if let learnMoreStep = step as? SBALearnMoreActionStep, learnMoreStep.learnMoreAction != nil {
            return true
        } else {
            return false
        }
    }
    
    /**
     Populates and configures the internal properties of an SBAStepHeaderView.
     @param   headView   the SBAStepHeaderView to configure
     */
    open func setupHeaderView(_ headView: SBAStepHeaderView) {
        
        if let instructionStep = step as? ORKInstructionStep {
            // set image, check for both .image and .iconImage
            if let image = instructionStep.image {
                headView.image = image
            }
            else if let image = instructionStep.iconImage {
                headView.image = image
            }
        }
        
        // setup progress
        headView.progressView.totalSteps = stepCount
        headView.progressView.currentStep = stepIndex
        
        
        // setup label text
        headView.headerLabel.text = step?.title
        headView.detailsLabel.text = step?.text
        
        
        // populate 'prompt' label if we have any text
        // TODO: Josh Bruhin, 6/12/17 - currently, if we have a form step, we use the 'footnote'
        // property. Using 'footnote' may not work because that's used for Sage
        // copyright-type info on the registration step. We may want a dedicated field in the
        // model for this. Maybe we subclass SBANavigableFormStep and add a 'prompt' property?
        
        if let formStep = step as? ORKFormStep {
            headView.promptLabel.text = formStep.footnote
        }
        
        // learn more button
        if shouldShowLearnMore() {
            
            headView.shouldShowLearnMore = true
            
            // add our action
            headView.learnMoreButton.addTarget(self, action: #selector(showLearnMore), for: .touchUpInside)
            
            // set the title
            headView.learnMoreButton.setTitle(learnMoreButtonTitle ?? Localization.buttonLearnMore(), for: .normal)
        }
        
        if step is ORKFormStep {
            
            // We have a minimum height for ORKFormSteps because these step usually have just a title and
            // description and the design generally calls for quite a bit of margin above and below the labels.
            // So we set a minimum size
            
            headView.minumumHeight = constants().formStepMinHeaderHeight
        }
    }
    
    /**
     Populates and configures the internal properties of an SBAStepNavigationView.
     @param   navView   the SBAStepNavigationView to configure
     */
    open func setupNavigationView(_ navView: SBAStepNavigationView?) {
        navView?.backgroundColor = UIColor.white
        
        // setup the button actions
        navView?.nextButton.addTarget(self, action: #selector(nextHit), for: .touchUpInside)
        navView?.previousButton.addTarget(self, action: #selector(previousHit), for: .touchUpInside)
        
        // show or hide our prev and next buttons
        navView?.nextButton.isHidden = !hasNextStep()
        navView?.previousButton.isHidden = !hasPreviousStep()
    }
    
    // MARK: Actions
    
    /**
     The default action for the Next Button in the SBAStepNavigationView.
     */
    open func nextHit() {
        
        // need to indicate user has chosen to continue so the result will be updated
        // with their answers, otherwise the orginal result will be returned
        
        userHasContinued = true
        goForward()
    }
    
    /**
     The default action for the Previous Button in the SBAStepNavigationView.
     */
    open func previousHit() {
        goBackward()
    }
    
    /**
     The default action for the Learn More Button in the SBAStepHeaderView.
     */
    open func showLearnMore() {
        
        guard let learnMoreStep = step as? SBALearnMoreActionStep, let learnMore = learnMoreStep.learnMoreAction else {
            return
        }
        
        // we need to get a reference to our ORKTaskViewController. In most cases, this will be
        // our delegate, but it's possible our delegate will be a SBAGenericPageStepViewController.
        // This is true for the consent scenes. If this is the case, then our delegate's delegate
        // should be the ORKTaskViewController
        
        let taskVC: ORKTaskViewController?
        
        if let pageStepController = self.delegate as? SBAGenericPageStepViewController {
            taskVC = pageStepController.delegate as? ORKTaskViewController
        } else {
            taskVC = self.delegate as? ORKTaskViewController
        }
        
        if taskVC != nil {
            learnMore.learnMoreAction(for: learnMoreStep, with: taskVC!)
        }
    }
    
    /**
     The 'SBAStepTextFieldTableViewCell' to use. Override to provide a custom instances of this class.
     @param     reuseIdentifier     A String representing the reuse identifier of the cell
     @return                        The 'SBAStepTextFieldTableViewCell' class to use
     */
    open func textFieldCell(reuseIdentifier: String) -> SBAStepTextFieldTableViewCell {
        return SBAStepTextFieldTableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    
    // MARK: UITableView Datasource
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData!.sections[section].itemCount()
    }
    open func numberOfSections(in tableView: UITableView) -> Int {
        return tableData!.sections.count
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // subclass may override
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // subclass may override
        return 0.0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "\(indexPath.section)-\(indexPath.row)"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        let tableItem = tableData!.tableItem(at: indexPath)
        let answerFormat = tableItem?.formItem?.answerFormat?.implied()
        let type = answerFormat?.questionType
        
        if cell == nil {
            
            // configure cell
            
            if type == .decimal || type == .integer || type == .text {
                
                // Create a textField based cell
                let fieldCell = textFieldCell(reuseIdentifier: identifier)
                fieldCell.textField.delegate = self
                fieldCell.selectionStyle = .none
                
                // setup our keyboard accessory view, which is a standard navigationView
                let navView = SBAStepNavigationView()
                setupNavigationView(navView)
                
                // update enabled state of the next button
                navView.nextButton.isEnabled = tableData!.allAnswersValid()
                
                // using auto layout to constrain the navView to fill its superview after adding it to the textfield
                // as its inputAccessoryView doesn't work for whatever reason. So we get the computed height from the
                // navView and manually set its frame before assigning it to the text field
                
                let navHeight = navView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                let navWidth = UIScreen.main.bounds.size.width
                navView.frame = CGRect(x: 0, y: 0, width: navWidth, height: navHeight)
                
                fieldCell.textField.inputAccessoryView = navView
                
                // set keyboard type
                if let textAnswerFormat = answerFormat as? ORKTextAnswerFormat {
                    // use the keyboard type defined for this step
                    fieldCell.textField.keyboardType = textAnswerFormat.keyboardType
                }
                else {
                    // use the keyboard type appropriate for the questionType
                    fieldCell.textField.keyboardType = type == .text ? .default : .numberPad
                }
                
                cell = fieldCell
                
            } else {
                
                // Create a choice based cell
                let choiceCell = SBAStepChoiceTableViewCell(style: .default, reuseIdentifier: identifier)
                cell = choiceCell
            }
        }
        
        // populate cell
        
        if type == .decimal || type == .integer || type == .text {
            
            if let textFieldCell = cell as? SBAStepTextFieldTableViewCell {
                
                if let customField = textFieldCell.textField as? SBAStepTextField {
                    customField.indexPath = indexPath
                }
                
                // if we have an answer, populate the text field
                let itemGroup = tableData!.itemGroup(at: indexPath)
                if itemGroup!.isAnswerValid {
                    if let answerNumber = itemGroup?.answer as? NSNumber {
                        textFieldCell.textField.text = answerNumber.stringValue
                    }
                    else if let answerString = itemGroup?.answer as? String {
                        textFieldCell.textField.text = answerString
                    }
                }
            }
        } else {
            if let choiceCell = cell as? SBAStepChoiceTableViewCell {
                choiceCell.choiceValueLabel.text = tableItem?.choice?.choiceText
                choiceCell.isSelected = tableItem!.selected
            }
        }
        
        return cell!
    }
    
    // MARK: UITableView Delegate
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tableItem = tableData!.tableItem(at: indexPath)
        let answerFormat = tableItem?.formItem?.answerFormat?.implied()
        let type = answerFormat?.questionType
        
        if type == .decimal || type == .integer || type == .text {
            
            // need to get our cell and tell its textField to become first responder
            if let customCell = tableView.cellForRow(at: indexPath) as? SBAStepTextFieldTableViewCell {
                customCell.textField.becomeFirstResponder()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        else {
            
            tableData!.selectAnswer(selected: true, at: indexPath)
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            
            // Dismiss other textField's keyboard
            tableView.endEditing(false)
        }
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // subclass
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: UITextField delegate
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let customField = textField as? SBAStepTextField {
            // need to scroll our tableView to the appropriate indexPath. We save our scrollOffset
            // so we can scroll back when user is done editing
            
            savedVerticalScrollOffet = tableView!.contentOffset.y
            tableView?.scrollToRow(at: customField.indexPath!, at: .bottom, animated: true)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        // scroll back to our saved offset
        tableView?.setContentOffset(CGPoint(x: 0.0, y: savedVerticalScrollOffet), animated: true)
    }
    
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        if let customTextField = textField as? SBAStepTextField {
            if let itemGroup = tableData!.itemGroup(at: customTextField.indexPath!) {
                
                var answer = ORKNullAnswerValue()
                
                // need to determine if we need a string or a number
                var returnValue = true
                if let numericAnswerFormat = itemGroup.formItem.answerFormat as? ORKNumericAnswerFormat {
                    
                    let sanitziedText = numericAnswerFormat.sanitizedTextFieldText(textAfterUpdate, decimalSeparator: numberFormatter.decimalSeparator)
                    textField.text = sanitziedText
                    
                    if sanitziedText!.characters.count > 0 {
                        let answerNumber = NSDecimalNumber(string: sanitziedText, locale: Locale.current)
                        if numericAnswerFormat.isAnswerValid(answerNumber) {
                            answer = answerNumber
                        }
                    }
                    
                    // return false since we're manually updating the text field with the sanitized text
                    returnValue = false
                }
                else {
                    
                    if itemGroup.formItem.answerFormat!.isAnswerValid(textAfterUpdate) {
                        answer = textAfterUpdate
                    }
                }
                
                tableData!.saveAnswer(answer as AnyObject, at: customTextField.indexPath!)
                
                // need to update enabled state of next button in the textFields inputAccessoryView,
                // which is a SBAStepNavigationView
                
                if let navView = textField.inputAccessoryView as? SBAStepNavigationView {
                    navView.nextButton.isEnabled = tableData!.allAnswersValid()
                }
                return returnValue
            }
        }
        
        return true
    }
    
    // MARK: UIScrollView delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateShadows()
    }
    
    open func updateShadows() {
        guard let navigationView = navigationView else { return }
        let maxY = tableView!.contentSize.height + tableView!.contentInset.top - (tableView!.bounds.size.height - navigationView.bounds.size.height)
        navigationView.shouldShowShadow = tableView!.contentOffset.y < maxY
    }

    
    // MARK: KeyboardNotification delegate
    
    func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                
                // set the tableView bottom inset to default
                var inset = tableView!.contentInset
                inset.bottom = tableViewInsetBottom
                tableView?.contentInset = inset
                
            } else {
                
                // change tableView contentInset bottom to be equal to the height of the keyboard plue
                // our constant for the bottom margin
                
                var contentInset = tableView?.contentInset
                contentInset!.bottom = endFrame!.size.height + constants().mainViewBottomMargin
                tableView!.contentInset = contentInset!
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    // MARK: SBAGenericStepDataSource delegate
    
    public func answersDidChange() {
        
        // update enabled state of next button
        navigationView?.nextButton.isEnabled = tableData!.allAnswersValid()
    }
}


public extension CGFloat {
    
    /**
     Occasionally we do want UI elements to be a little bigger or wider on bigger screens,
     such as with label widths. This can be used to increase values based on screen size. It
     uses the small screen (320 wide) as a baseline. This is a much simpler alternative to
     defining a matrix with screen sizes and constants and achieves much the same result
     */
    func proportionalToScreenWidth() -> CGFloat {
        let baselineWidth = CGFloat(320.0)
        return UIScreen.main.bounds.size.width / baselineWidth * self
    }
}


public extension UIImage {
    
    /**
     Re-color an image.
     */
    
    func applyColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        color.setFill()
        
        context!.translateBy(x: 0, y: self.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        context!.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        context!.draw(self.cgImage!, in: rect)
        
        
        context!.setBlendMode(CGBlendMode.sourceIn)
        context!.addRect(rect)
        context!.drawPath(using: CGPathDrawingMode.fill)
        
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coloredImage!
    }
}

class SBAGenericStepUIConfig {
    
    /**
     Defines whether or not a drop shadow is shown below the top edge of the navigation view. The shadow
     is only shown if content is underlapping the navigation view.
     */
    class func shouldShowNavigationViewShadow() -> Bool { return true }
    
    /**
     Defines whether or not the navigation view is always pinned to the bottom of the screen, with content
     scrolling underneath it, or it's embedded in the footerView of the tableView, in which case it
     scrolls with the content.
     */
    class func shouldUseStickyNavigationView() -> Bool { return true }
    
    /**
     Defines if the progress view, which shows the number of steps completed in a multi-step task,
     should be shown at the top of the screen underneath the navigation bar.
     */
    class func shouldShowProgressView() -> Bool { return true }
    
    /**
     Defines which back button position should be used.
     */
    class func backButtonPosition() -> backButtonPosition { return .navigationBar }
}

/**
 Defines possible positions of back button for step navigation.
 */
public enum backButtonPosition {
    
    /**
     Places back button in the navigation bar.
     */
    case navigationBar
    
    /**
     Places back button in the navigation view, which is either pinned to the bottom of the screen
     or embedded in the tableView.footerView.
     */
    case navigationView
}

