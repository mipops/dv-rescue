/*  Copyright (c) MIPoPS. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-3-Clause license that can
 *  be found in the LICENSE.txt file in the root of the source tree.
 */

//---------------------------------------------------------------------------
#pragma once

#include <cstddef> //for std::size_t, native size_t isn't avaiable in obj-c++ mode
#include <string>

class file;

//***************************************************************************
// Class FileWrapper
//***************************************************************************

class FileWrapper {
public:
    FileWrapper(file* File);
    void Parse_Buffer(const std::uint8_t* Buffer, std::size_t Buffer_Size);

 private:
    file* File;
};
