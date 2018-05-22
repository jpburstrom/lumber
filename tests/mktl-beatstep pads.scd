
MKtlDesc.addFolder("/Users/johannes/projects/lumber/kod/lib/")
MKtl('art').free; MKtl('art', "*beatstep-padCC*", true)
MKt
MKtl('art').desc.openTestCode
MKtl('art').rebuild
MKtl('art').gui

MKtl('art1').desc.openTestCode

MKtl('art').elAt(0, \pad, 0).action = { |el, grp|
    // grp.postln;
    if (grp.dict[\on] == el) {
        "tgl".postln;
        ~tgl = 1 - ~tgl;

    } {
        if (grp.dict[\off] == el) {
           grp[0].value = ~tgl;
        }
    }


}


MKtl('art').elAt(0, \pad, 0).value = 1

.dict[\on]
isOn

MKtl('art').elAt(0, \pad).elemDesc

MKtl('art').device