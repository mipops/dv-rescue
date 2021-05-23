/*  Copyright (c) MIPoPS. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-3-Clause license that can
 *  be found in the LICENSE.txt file in the root of the source tree.
 */

#include "Common/ProcessFileWrapper.h"
#include "Common/ProcessFile.h"

using namespace std;

FileWrapper::FileWrapper(file* File) : File(File)
{
}

void FileWrapper::Parse_Buffer(const uint8_t* Buffer, size_t Buffer_Size)
{
    File->Parse_Buffer(Buffer, Buffer_Size);
}
