function [rows, mode] = lbl_parse(file)
%lbl_parse parses a radar lbl file to determine necessary information for
%data processing
fid = fopen(file);
ln_num = 1;
while (ln_num < 34)
    data = fgetl(fid);
    ln_num = ln_num + 1;
end
rows = str2num(erase(data,' FILE_RECORDS                 = '));

while (ln_num < 43)
    data = fgetl(fid);
    ln_num = ln_num + 1;
end
mode = str2num(erase(data, ' INSTRUMENT_MODE_ID            = SS'));

