require 'ffi'

module LibBluetooth
    SOL_HCI = 0
    HCI_FILTER = 2
    HCI_MAX_EVENT_SIZE  = 260

    BT_EIR_NAME_SHORT = 0x08
    BT_EIR_NAME_COMPLETE = 0x09

    extend FFI::Library
    ffi_lib "/usr/lib/libbluetooth.so"
    attach_function :hci_open_dev, [:int], :int
    attach_function :hci_close_dev, [:int], :int
    attach_function :hci_get_route, [:pointer], :int
    attach_function :hci_le_set_scan_parameters, [:int, :uint8, :uint16, :uint16, :uint8, :uint8, :int], :int
    attach_function :hci_le_set_scan_enable, [:int, :uint8, :uint8, :int], :int
end


# these flags where some massive guesswork
# mostly because unpack('b*') is such amazing help.
# check out hci_filter.c for finding the right bit
# and make sure to debug with unpack('B*') ...

class HciFilter < BinData::Record
    endian :little

    bit1  :hci_command_pkt
    bit1  :hci_acldata_pkt
    bit1  :hci_scodata_pkt
    bit1  :hci_event_pkt
    bit1  :hci_reserved_1
    bit1  :hci_reserved_2
    bit1  :hci_reserved_3
    bit1  :hci_vendor_pkt

    bit8  :hci_reserved_n9_16
    bit8  :hci_reserved_n17_24
    bit8  :hci_reserved_n25_32

    bit32 :event_mask_unused

    bit8 :event_mask_unused_1_8
    bit8 :event_mask_unused_9_16
    bit8 :event_mask_unused_17_24

    bit1 :event_mask_unused_25
    bit1 :evt_le_meta_event
    bit1 :event_mask_unused_26
    bit1 :event_mask_unused_27
    bit1 :event_mask_unused_29
    bit1 :event_mask_unused_30
    bit1 :event_mask_unused_31
    bit1 :event_mask_unused_32

    uint16 :opcode
    uint16 :padding_garbage

end

class BLHeader < BinData::Record
    endian :little
    uint8  :dunno1
    uint8  :dunno2
    uint8  :probably_payload_size
    uint8  :subtype
end

class BLEAdversingReport < BinData::Record
    uint8  :garbage
    uint8  :garbage2
    uint8  :bdaddr_type
    array  :bdaddr, :type => :uint8, :initial_length => 6
    uint8  :data_len
    string :data, :read_length => lambda { data_len }
end
