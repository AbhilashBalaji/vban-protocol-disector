-- VBAN Dissector
vban_proto = Proto("vban", "VBAN Protocol")

-- VBAN Protocol Fields
local f_vban = ProtoField.uint32("vban.Name", "vban")
local f_format_sr = ProtoField.uint8("vban.format_sr", "Sample Rate index", base.DEC)
local f_format_nbs = ProtoField.uint8("vban.format_nbs", "Samples per Frame", base.DEC)
local f_format_nbc = ProtoField.uint8("vban.format_nbc", "Number of Channels", base.DEC)
local f_format_bit = ProtoField.uint8("vban.format_bit", "mask", base.DEC)
local f_streamname = ProtoField.string("vban.streamname", "Stream Name")
local f_nuFrame = ProtoField.uint32("vban.nuFrame", "Frame Number", base.DEC)
local f_payload = ProtoField.bytes("vban.payload", "Payload")

vban_proto.fields = {f_vban, f_format_sr, f_format_nbs, f_format_nbc, f_format_bit, f_streamname, f_nuFrame, f_payload}

-- VBAN Dissector Function
function vban_proto.dissector(buffer, pinfo, tree)
    local length = buffer:len()
    if length < 28 then
        -- Not enough bytes to dissect VBAN header
        return
    end

    pinfo.cols.protocol = vban_proto.name

    local subtree = tree:add(vban_proto, buffer(), "VBAN Protocol Data")
    subtree:add(f_vban, buffer(0, 4))
    subtree:add(f_format_sr, buffer(4, 1))
    subtree:add(f_format_nbs, buffer(5, 1))
    subtree:add(f_format_nbc, buffer(6, 1))
    subtree:add(f_format_bit, buffer(7, 1))
    subtree:add(f_streamname, buffer(8, 16))
    subtree:add(f_nuFrame, buffer(24, 4))

    -- Check for payload
    if length > 28 then
        subtree:add(f_payload, buffer(28, length - 28))
    end
end

-- Initialization
local udp_port = DissectorTable.get("udp.port")
udp_port:add(13251, vban_proto)
