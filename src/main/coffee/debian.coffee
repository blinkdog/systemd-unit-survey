# debian.coffee
# Copyright 2018 Patrick Meade.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#----------------------------------------------------------------------

_ = require "underscore"
fs = require "fs"
{inspect} = require "util"
path = require "path"
{readUnitsFromContentsPath} = require "./contents"

RELEASES = [
  "buster"
  "buster-proposed-updates"
  "buster-updates"
  "stretch"
  "stretch-backports"
  "stretch-proposed-updates"
  "stretch-updates"
]

SECTIONS = [
  "contrib"
  "main"
  "non-free"
]

contentSpec = (release, section) ->
  return
    release: release
    section: section
    path: "/home/blinkdog/data/debian/dists/#{release}/#{section}/Contents-amd64.gz"

CONTENTS = _.flatten (contentSpec x,y for y in SECTIONS for x in RELEASES)

getUniqPackages = (unitList) ->
  unitContainingPackages = []
  for unit in unitList
    unitContainingPackages = unitContainingPackages.concat unit.pkgs
  unitContainingPackages.sort()
  uniqUnitPackages = _.uniq unitContainingPackages, true
  return uniqUnitPackages

getUnitStats = (unitList) ->
  typeStat = {}
  for unit in unitList
    ext = path.extname unit.path
    typeStat[ext] ?= 0
    typeStat[ext]++
  return typeStat

do ->
  for spec in CONTENTS
    spec.units = await readUnitsFromContentsPath spec.path
    spec.uniqPackages = getUniqPackages spec.units
    spec.unitStats = getUnitStats spec.units
    console.log "#{spec.release}/#{spec.section}: #{spec.units.length} units in #{spec.uniqPackages.length} packages"
    console.log inspect spec.unitStats

#----------------------------------------------------------------------
# end of debian.coffee
