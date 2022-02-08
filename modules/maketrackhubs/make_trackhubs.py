#!/usr/qc/env python
'''
Created on Mar 7, 2013

@author: gabrielp

Given a list of * files makes trackhubs for those files

Assumes that you have passwordless ssh setup between the two servers you are transfering files from

'''

import argparse
import re
import os
from itertools import groupby

from trackhub import Hub, GenomesFile, Genome, TrackDb, Track, AggregateTrack, SuperTrack

from trackhub.upload import upload_hub, upload_track


def remove_plus_and_pct(string):
    """
    Args:
        string:
    Returns: string after removing all + and all % characters
    """
    # clean_string = re.sub(r'[%+]+', '', string)   # old code
    # clean_string = re.sub(r'[%+]+', '', string)   # equivalent to above, but still a regexp, let s use replace instead
    clean_string = string.replace('+','').replace('%','')
    return clean_string





if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Takes in files to turn into trackhub')

    # tracks files
    ##############
    parser.add_argument('files', nargs='+', help='Files to turn into track hub')

    # namings
    #########
    parser.add_argument('--hub',    help="hub name (no spaces)", required=True)
    parser.add_argument('--genome', help="genome name",          required=True)

    # upload (in fact run_local=True)
    ########
    #parser.add_argument('--no_s3', default=False, action="store_true", help="upload to defined server instead of s3")
    #parser.add_argument('--serverscp', default="tscc-login2.sdsc.edu", help="server to SCP to")
    #parser.add_argument('--user', default='adomissy', help="that is uploading files")
    parser.add_argument('--uploaddir', default='trackhubs_upload_dir', help="directory to upload files to if not uploading to aws")

    # web access
    ############
    parser.add_argument('--urldomain', default="alaindomissy.github.io", help="url domain for public access to trackhubs")
    parser.add_argument('--urldir',    default="", help="url directory for public access to trackhubs")

    # hub labels
    ############
    parser.add_argument('--hub_short_label', default=None, help="short label for hub")
    parser.add_argument('--hub_long_label',  default=None, help="long label for hub")
    parser.add_argument('--hub_email',       default='adomissy@ucsd.edu', help="email for hub")

    # name parts grouping
    #####################
    parser.add_argument('--sep', default=".", help="Seperator")
    parser.add_argument('--num_sep', default=2, type=int, help="Number of seperators deep to group on")


    ###########################################################################
    args = parser.parse_args()

    # hard coding serverscp, in variable HOST
    HOST="localhost"
    # hard coding user, in variable USER
    USER="user"

    GENOME = args.genome
    # hack for tutorial dataset so it is easy to view in ucsd genome browser
    if GENOME == 'hg19chr19kbp255':
        GENOME == 'hg19'

    # default label settings
    ########################
    if not args.hub_short_label:
        args.hub_short_label = args.hub
    if not args.hub_long_label:
        args.hub_long_label = args.hub_short_label

    uploaddir = os.path.join(args.uploaddir, args.hub)

    #if args.no_s3:
    #    #URLBASE = os.path.join("http://sauron.ucsd.edu/Hubs", args.hub)
    #    URLBASE = os.path.join("http://" + args.serverweb + "/Hubs", args.hub)
    #else:
    #    URLBASE = os.path.join("https://s3-us-west-1.amazonaws.com/sauron-yeo/", args.hub)
    URLBASE = os.path.join("http://" + args.urldomain + "/" + args.urldir + "/", args.hub)
    #URLBASE = 'http://alaindomissy.github.io/mytrackhubs'

    # create data structures
    ########################

    hub = Hub(hub=args.hub,
              short_label=args.hub_short_label,
              long_label=args.hub_long_label,
              email=args.hub_email,
    )
    hub.upload_fn = uploaddir

    genomes_file = GenomesFile()
    hub.add_genomes_file(genomes_file)

    genome = Genome(GENOME)
    genomes_file.add_genome(genome)

    trackdb = TrackDb()
    genome.add_trackdb(trackdb)

    supertrack = SuperTrack(name=args.hub,
                            short_label=args.hub,
                            long_label=args.hub)

    # separate bigwigs, bigbeds and others for different processing methods
    #######################################################################

    bigwig_files = [file for file in args.files if file.endswith(".posbw") or file.endswith(".negbw") or file.endswith(".bw") or file.endswith(".bigWig")or file.endswith(".bigwig")]
    bigbed_files = [file for file in args.files if file.endswith(".bb") or file.endswith(".bigBed") or file.endswith(".bigbed")]
    # not used
    #other_files = [file for file in args.files if (file not in bigwig_files and file not in bigbed_files )]

    # process bigwig files , regrouoped by third 2 dot-sepatarated name-parts, as multitracks
    ##########################################################################################
    key_func = lambda x: x.split(args.sep)[:args.num_sep]
    for group_key, group_bigwig_files in groupby(sorted(bigwig_files, key=key_func), key_func):

        group_bigwig_files_list = list(group_bigwig_files)

        print "-----------------------------------------"
        print "processing bigwig files group with key :" , group_key
        print "comprised of following files:", group_bigwig_files_list
        print "-----------------------------------------"

        long_name = remove_plus_and_pct(os.path.basename(args.sep.join(group_key[:args.num_sep])))
        aggregate = AggregateTrack(
            name=long_name,
            tracktype='bigWig',
            short_label=long_name,
            long_label=long_name,
            aggregate='transparentOverlay',
            showSubtrackColorOnUi='on',
            autoScale='on',
            priority='1.4',
            alwaysZero='on',
            visibility="full"
            )
        
        for bigwigfile in group_bigwig_files_list:
            print "--------------------------"
            print "bigwigfile",  bigwigfile
            print "--------------------------"
            base_track = remove_plus_and_pct(os.path.basename(bigwigfile))
            split_track = base_track.split(args.sep)
            long_name = args.sep.join(split_track[:args.num_sep] + split_track[-3:])
            color = "0,100,0" if "pos" in bigwigfile else "100,0,0"
            track = Track(
                name= long_name,
                url = os.path.join(URLBASE, GENOME, base_track),
                tracktype = "bigWig",
                short_label=long_name,
                long_label=long_name,#######in fact run_local =
                color = color,
                local_fn = bigwigfile,
                remote_fn = os.path.join(uploaddir, GENOME, base_track)
                )
            aggregate.add_subtrack(track)
        supertrack.add_track(aggregate)
        trackdb.add_tracks(aggregate)

    # process bigbed files as single track
    ######################################
    for bigbed_file in bigbed_files:
        color = "0,100,0" if "pos" in bigbed_file else "100,0,0"
        base_track = remove_plus_and_pct(os.path.basename(bigbed_file))
        long_name = args.sep.join(base_track.split(args.sep)[:args.num_sep]) + ".bb"
        track = Track(
            name=long_name,
            url=os.path.join(URLBASE, GENOME, base_track),
            tracktype="bigBed",
            short_label=long_name,
            long_label=long_name,
            color=color,
            local_fn=bigbed_file,
            remote_fn=os.path.join(uploaddir, GENOME, base_track),
            visibility="full"
        )
        trackdb.add_tracks(track)
        supertrack.add_track(track)
    trackdb.add_tracks(supertrack)
    result = hub.render()
    hub.remote_fn = os.path.join(uploaddir, "hub.txt")

    # process bigbed files  (bam?)
    ######################
    ##  UNUSED
    # if bigwigfile.endswith(".bw") or bigwigfile.endswith('.bigWig'): tracktype = "bigWig"
    # if bigwigfile.endswith(".bb") or bigwigfile.endswith('.bigBed'): tracktype = "bigBed"
    # if bigwigfile.endswith(".bam"):                                  tracktype = "bam"

    # 'upolading' (locally)
    ########################
    for track in trackdb.tracks:
        #print("upload_track(track=" + track.__repr__() + ", host=" + args.serverscp + ", user=" + args.user + "run_local=True")
        #upload_track(track=track, host=args.serverscp, user=args.user)
        # upload_track(track=track, host=args.serverscp, user=args.user, run_s3=args.no_s3)
        pass
        upload_track(track=track, host=HOST, user=USER, run_local=True)

    #print("upload_hub(hub=" + hub.__repr__() + ", host=" + args.serverscp + ", user=" + args.user + "run_local=True")
    #upload_hub(hub=hub, host=args.serverscp, user=args.user)
    # upload_hub(hub=hub, host=args.serverscp, user=args.user, run_s3=args.no_s3)
    pass
    upload_hub(hub=hub, host=HOST, user=USER, run_local=True)
