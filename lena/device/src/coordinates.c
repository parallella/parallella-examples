/*
  coordinates.c

  Copyright (C) 2012 Adapteva, Inc.
  Contributed by Yaniv Sapir <yaniv@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program, see the file COPYING.  If not, see
  <http://www.gnu.org/licenses/>.
*/


/* set coordinates, used by linker to find dedicated memory "slice" in the external DRAM*/ 
extern int _CORE_ROW_;
asm(".global __CORE_ROW_;");

extern int _CORE_COL_;
asm(".global __CORE_COL_;");



asm(".set __CORE_ROW_,minRow;");
asm(".set __CORE_COL_,minCol;");
