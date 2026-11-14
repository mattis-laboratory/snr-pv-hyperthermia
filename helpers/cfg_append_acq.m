function [cfg] = cfg_append_acq(cfg,OEP,PPD,recording)


cfg.eegFs                     = OEP.metadata.sampleRate;
cfg.photoFs                   = PPD.sampling_rate;
cfg.datestamp                 = PPD.date_time(1:10);
if (cfg.hasOpto) == true
    cfg.ADC_bitVolt               = [recording.info.continuous(cfg.NIstream).channels(1).bit_volts].';
end

end