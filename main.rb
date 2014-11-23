require 'bindata'
require 'socket'
require './libbluetooth'

def eir_parse_name(eir)
    offset = 0
    while (offset < eir.size)
        field_len = eir[0]

        #Check for the end of EIR
        break if (field_len == 0)
        break if (offset + field_len > eir.size)

        if eir[1] == LibBluetooth::BT_EIR_NAME_SHORT || eir[1] ==  LibBluetooth::BT_EIR_NAME_COMPLETE
            name_len = field_len - 1;
            return eir[2, name_len].pack("C*")
        end

        offset += field_len + 1;
        eir += field_len + 1;
    end

    return "(unknown)"
end

def ba2str(ba)
    sprintf "%2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X", ba[5], ba[4], ba[3], ba[2], ba[1], ba[0]
end

def print_advertising_devices(dd)
    hci = HciFilter.new
    hci.hci_event_pkt = 1
    hci.evt_le_meta_event = 1

    so = Socket.for_fd(dd)
    p so.setsockopt(LibBluetooth::SOL_HCI, LibBluetooth::HCI_FILTER, hci.to_binary_s)

    loop  do
        ss = StringIO.new
        ss << so.read(LibBluetooth::HCI_MAX_EVENT_SIZE)
        ss.rewind

        header = BLHeader.read(ss)

        if (header.subtype != 0x02)
            puts "t:#{header.subtype}"
            next
        end

        adv = BLEAdversingReport.read(ss)
        puts "#{ba2str adv.bdaddr} #{eir_parse_name adv.data.unpack('C*')}"
        p adv.data.unpack("C*")
    end
end


dev_id = LibBluetooth.hci_get_route(nil);
throw "No hci device available" if dev_id < 0

dd = LibBluetooth.hci_open_dev(dev_id);
throw "cannot open hci device" if dd < 0

own_type = 0x00
scan_type = 0x01
filter_type = 0
filter_policy = 0x00
interval = 0x0010
window = 0x0010

err = LibBluetooth.hci_le_set_scan_parameters(dd, scan_type, interval, window, own_type, filter_policy, 10000)
throw :hci_le_set_scan_parameters if err < 0

err = LibBluetooth.hci_le_set_scan_enable(dd, 0x01, 0x00, 10000);
throw :hci_le_set_scan_enable if err < 0

print_advertising_devices(dd);

err = LibBluetooth.hci_le_set_scan_enable(dd, 0x00, 0x00, 10000);
throw :hci_le_set_scan_enable if err < 0

LibBluetooth.hci_close_dev(dd);
