#!/usr/bin/env python3

# This file is part of MGnify genome analysis pipeline.
#
# MGnify genome analysis pipeline is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# MGnify genome analysis pipeline is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with MGnify genome analysis pipeline. If not, see <https://www.gnu.org/licenses/>.

# Modified from: https://github.com/MikeTrizna/assembly_stats - assembly_stats.py

import numpy as np
from itertools import groupby
import sys


def run_assembly_stats(infilename):
    contig_lens, gc_cont = read_genome(infilename)
    contig_stats = calculate_stats(contig_lens, gc_cont)
    return contig_stats


def fasta_iter(fasta_file):
    fh = open(fasta_file, "r")
    fa_iter = (x[1] for x in groupby(fh, lambda line: line[0] == ">"))
    for header in fa_iter:
        # drop the ">"
        header = next(header)[1:].strip()
        # join all sequence lines to one.
        seq = "".join(s.upper().strip() for s in next(fa_iter))
        yield header, seq


def read_genome(fasta_file):
    gc = 0
    total_len = 0
    contig_lens = []
    for _, seq in fasta_iter(fasta_file):
        contig_list = [seq]
        for contig in contig_list:
            if len(contig):
                gc += contig.count("G") + contig.count("C")
                total_len += len(contig)
                contig_lens.append(len(contig))
    gc_cont = round((gc / total_len) * 100, 2)
    if gc_cont.is_integer():
        gc_cont = int(gc_cont)
    return contig_lens, gc_cont


def calculate_stats(seq_lens, gc_cont):
    stats = {}
    seq_array = np.array(seq_lens)
    stats["N_contigs"] = seq_array.size
    stats["GC_content"] = gc_cont
    sorted_lens = seq_array[np.argsort(-seq_array)]
    stats["Length"] = int(np.sum(sorted_lens))
    csum = np.cumsum(sorted_lens)
    level = 50
    nx = int(stats["Length"] * (level / 100))
    csumn = min(csum[csum >= nx])
    l_level = int(np.where(csum == csumn)[0])
    n_level = int(sorted_lens[l_level])
    stats["N" + str(level)] = n_level
    return stats


if __name__ == "__main__":
    infilename = sys.argv[1]
    contig_stats = run_assembly_stats(infilename)
    print(contig_stats)
