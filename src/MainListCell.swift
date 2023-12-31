
import UIKit

class MainListCell: UITableViewCell {

    var item: Item? {
        didSet {
            textLabel?.text = item?.title
            detailTextLabel?.text = item?.subtitle
            accessoryType = item?.destination == nil ? .none : .disclosureIndicator
            imageView?.image = item?.image

            if let c = item?.color {
                backgroundColor = c
            }
            else {
                detailTextLabel?.textColor = .secondaryLabel
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        textLabel?.text = nil
        detailTextLabel?.text = nil
        imageView?.image = nil
    }

}

private extension MainListCell {
    func setup() {
        imageView?.tintColor = .secondaryLabel
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
    }
}
