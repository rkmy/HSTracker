/*
 * This file is part of the HSTracker package.
 * (c) Benjamin Michotte <bmichotte@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Created on 19/02/16.
 */

import Foundation

enum CardMark: Int {
    case none,
    coin,
    returned,
    mulliganed,
    created,
    drawnByEntity,
    kept,
    forged
}
