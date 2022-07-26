# Change Log
All notable changes to this project will be documented in this file.
`APControllers` adheres to [Semantic Versioning](http://semver.org/).

## [2.0.0](https://github.com/APUtils/APControllers/releases/tag/2.0.0)
Released on 2022-07-27.

#### Added
- UITableView .computeRowHeightAutomatically(...)
- UITableView .optimizeCellHeightComputations(...)

#### Changed
- Made controllers public
- Set `tableView.rowHeight = UITableView.automaticDimension` during `handleEstimatedSizeAutomatically`
- Using contentView instead of cell for layout

#### Improved
- Improved average height calculation speed
- Improved proxy speed


## [1.0.0](https://github.com/APUtils/APControllers/releases/tag/1.0.0)
Released on 01/12/2020.

#### Added
- Initial release of APControllers.
  - Added by [Anton Plebanovich](https://github.com/anton-plebanovich).
