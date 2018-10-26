# contents.coffee
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
LineByLineReader = require "line-by-line"
zlib = require "zlib"

lineCount = 0
parseCount = 0
unitCount = 0

CONTENTS_LINE_RE = /^([\S\s]+)\s+(\S+)$/
UNIT_FILE_RE = /\.automount$|\.device$|\.mount$|\.path$|\.service$|\.scope$|\.slice$|\.socket$|\.swap$|\.target$|\.timer$/

parseLine = (line) ->
  lineCount++
  parsed = CONTENTS_LINE_RE.exec line
  return null if not parsed?
  parseCount++
  path = parsed[1].trim()
  if UNIT_FILE_RE.test path
    unitCount++
    pkgs = parsed[2].split ","
    parsedPkgs = parsePackages pkgs
    return
      path: path
      pkgs: parsedPkgs
  return null

parsePackages = (pkgs) ->
  result = []
  for pkg in pkgs
    slashIndex = pkg.lastIndexOf "/"
    result.push pkg.substring slashIndex+1
  return result

readUnitsFromContentsPath = (contentsFilePath) ->
  inp = fs.createReadStream contentsFilePath
  gunzip = zlib.createGunzip()
  ginp = inp.pipe gunzip
  lr = new LineByLineReader ginp,
    encoding: "utf8"
    skipEmptyLines: true

  return new Promise (resolve, reject) ->
    unitList = []

    lr.on "error", (err) ->
      lr.close()
      return reject err

    lr.on "line", (line) ->
      parsed = parseLine line
      unitList.push parsed if parsed?

    lr.on "end", ->
      lr.close()
      return resolve unitList

exports.readUnitsFromContentsPath = readUnitsFromContentsPath

#----------------------------------------------------------------------
# end of contents.coffee
