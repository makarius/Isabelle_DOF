/**
 * Copyright (c) 2018 The University of Sheffield. All rights reserved.
 *               2018 The University of Paris-Sud. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

package com.logicalhacking.dof.converter

import java.io.{BufferedWriter, File, FileWriter}
import IoUtils._
import scala.util.matching.Regex


object DofConverter {
    val version = "0.0.0"
    def convertLaTeX(string:String):Either[LaTeXLexerError,String] = {
      LaTeXLexer(string) match {
                       case Left(err) => Left(err) 
                       case Right(tokens) => Right(LaTeXLexer.toString(tokens))
                   }
    }

    def convertFile(f: File):Option[(String,LaTeXLexerError)] = {
        val texFileName = f.getAbsolutePath()
        println("DOF Converter: converting " + texFileName
                + " (Not yet fully implemented!)")
        f.renameTo(new File(texFileName+".orig"))
     
        using(io.Source.fromFile(texFileName+".orig")) {
            inputFile =>
            using(new BufferedWriter(new FileWriter(new File(texFileName), true))) {
                outputFile =>
                outputFile.write("% This file was modified by the DOF LaTeX converter\n")
                val input = inputFile.getLines.reduceLeft(_+"\n"+_)
                
                convertLaTeX(input) match {
                    case Left(err)     => Some((texFileName, err))
                    case Right(output) => {
                                               outputFile.write(output)
                                               None
                                           }
                }
            }
        }
    }
    
    def processArgs(args: List[String]):Option[List[String]] =  {
        def printVersion() = {
            println("DOF LaTeX converter version "+version)
        }
        def printUsage() = {
            println("Usage:")
            println("    scala dof_latex_converter.jar [OPTIONS] [directory ...]")
            println("")
            println("Options:")
            println("      --version, -v    print version and exit")
            println("      --help,    -h    print usage inforamtion and exit")
        }
        args match {
             case Nil => Some(List[String]()) 
             case "-v"::Nil        => printVersion(); None 
             case "--version"::Nil => printVersion(); None 
             case "-h"::tail       => printUsage(); None 
             case "--help"::tail   => printUsage(); None 
             case file::tail       => processArgs(tail) match {
                                          case Some(files) => Some(file::files)
                                          case None        => None
                                      }
             case _                => printUsage();None
        }
    }
        
    def main(args: Array[String]): Unit = {
        val directories = processArgs(args.toList) match {
            case None => System.exit(1); List[String]()
            case Some(Nil) => List[String](".")
            case Some(l)   => l
        }

        val texFiles = directories.map(dir => recursiveListFiles(new File(dir), new Regex("\\.tex$"))
                                              .filterNot(_.length() == 0)).flatten

        println(texFiles)                                      
        val errors = texFiles.map(file => convertFile(file)).flatten
        if(!errors.isEmpty) {
            println()
            println("DOF LaTeX converter error(s):")
            println("=============================")
            errors.map{case (file:String, err:LaTeXLexerError) => println(file + ": " + err)}
            System.exit(1)
        }
        System.exit(0)
    }
}
