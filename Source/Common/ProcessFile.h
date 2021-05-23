/*  Copyright (c) MIPoPS. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-3-Clause license that can
 *  be found in the LICENSE.txt file in the root of the source tree.
 */

//---------------------------------------------------------------------------
#pragma once
#include "Common/Config.h"
#ifdef MEDIAINFO_DLL
    #include "MediaInfoDLL/MediaInfoDLL.h"
    #define MediaInfoNameSpace MediaInfoDLL
#elif defined MEDIAINFO_STATIC
    #include "MediaInfoDLL/MediaInfoDLL_Static.h"
    #define MediaInfoNameSpace MediaInfoDLL
#else
    #include "MediaInfo/MediaInfoList.h"
    #define MediaInfoNameSpace MediaInfoLib
#endif
#include "Common/Merge.h"
#include "TimeCode.h"
#include "MediaInfo/MediaInfo_Events.h"
#include <vector>
using namespace MediaInfoNameSpace;
using namespace std;

#ifdef ENABLE_AVFCTL
class AVFCtlWrapper;
#endif
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
void UpdateCerr(const string& Content = {});
string MediaInfo_Version();
//---------------------------------------------------------------------------

//***************************************************************************
// Class file
//***************************************************************************

class file
{
public:
    MediaInfo MI;
    std::vector<MediaInfo_Event_DvDif_Change_0*> PerChange;
    std::vector<MediaInfo_Event_DvDif_Analysis_Frame_1*> PerFrame;
    struct caption_fielddata
    {
        caption_fielddata(const MediaInfo_int8u* NewData)
        {
            Data[0] = NewData[0];
            Data[1] = NewData[1];
        }

        int compare(const MediaInfo_int8u* NewData)
        {
            if (Data[0] < NewData[0])
                return -1;
            if (Data[0] > NewData[0])
                return 1;
            if (Data[1] < NewData[1])
                return -1;
            if (Data[1] > NewData[1])
                return 1;
            return 0;
        }

        uint8_t Data[2];
    };
    struct captions_fielddata
    {
        captions_fielddata(MediaInfo_int64u NewStartFrameNumber) :
            StartFrameNumber(NewStartFrameNumber)
        {}
        MediaInfo_int64u StartFrameNumber;
        vector<caption_fielddata> Captions;
    };
    struct captions_data
    {
        double PTS;
        double DUR;
        vector<captions_fielddata> FieldData[2];
    };
    vector<captions_data> PerFrame_Captions_PerSeq_PerField;
    size_t FrameNumber;
    double FrameRate;

    file();
    ~file();

    void Parse(const String& FileName);
    void Parse_Buffer(const uint8_t* Buffer, size_t Buffer_Size);

    #ifdef ENABLE_AVFCTL
    bool TransportControlsSupported();
    void RewindToTimeCode(TimeCode TC);
    #endif
    void AddChange(const MediaInfo_Event_DvDif_Change_0* FrameData);
    void AddFrame(const MediaInfo_Event_DvDif_Analysis_Frame_1* FrameData);
    void AddFrame(const MediaInfo_Event_Global_Demux_4* FrameData);

    // Merge
    void Merge_Finish() { Merge.Finish(); }

private:
    size_t Merge_FilePos;
    dv_merge Merge;

    #ifdef ENABLE_AVFCTL
    AVFCtlWrapper* Controller;
    bool RewindMode;
    TimeCode RewindTo;
    #endif
};
