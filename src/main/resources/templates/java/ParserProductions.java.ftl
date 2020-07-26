[#ftl strict_vars=true]
[#--
/* Copyright (c) 2008-2020 Jonathan Revusky, revusky@javacc.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright notices,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name Jonathan Revusky, Sun Microsystems, Inc.
 *       nor the names of any contributors may be used to endorse 
 *       or promote products derived from this software without specific prior written 
 *       permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */
 --]

[#macro Generate]
     [@Productions/]
    [@firstSetVars/]
    [#if grammar.options.faultTolerant]
    [@finalSetVars/]
    [@followSetVars/]  
    [/#if]
    [#if parserData.scanAheadExpansions?size !=0]
       [@BuildLookaheads /]
     [/#if]
[/#macro]
 
[#macro Productions] 
 //=================================
 // Start of methods for BNF Productions
 //This code is generated by the ParserProductions.java.ftl template. 
 //=================================
  [#list grammar.parserProductions as production]
    [#set currentProduction = production]
    [@ParserProduction production/]
  [/#list]
[/#macro]

[#macro BuildLookaheads]
  private final boolean scanToken(TokenType expectedType) {
       if (remainingLookahead <=0) return true;
       if (currentLookaheadToken.getNext() == null) {
        Token nextToken = token_source.getNextToken();
        currentLookaheadToken.setNext(nextToken);
     } 
     currentLookaheadToken = currentLookaheadToken.getNext();
     TokenType type = currentLookaheadToken.getType();
     if (type != expectedType) return false;
     if (remainingLookahead != Integer.MAX_VALUE) remainingLookahead--;
     if (type == upToTokenType) remainingLookahead = 0;
     return true;
  }

  private final boolean scanToken(EnumSet<TokenType> types) {
     if (remainingLookahead <=0) return true;
     if (currentLookaheadToken.getNext() == null) {
        Token nextToken = token_source.getNextToken();
        currentLookaheadToken.setNext(nextToken);
     } 
     currentLookaheadToken = currentLookaheadToken.getNext();
     TokenType type = currentLookaheadToken.getType();
     if (!types.contains(type)) return false;
     if (remainingLookahead != Integer.MAX_VALUE) remainingLookahead--;
     if (type == upToTokenType) remainingLookahead = 0;
     return true;
  }

//====================================
 // Lookahead Routines
 //====================================
   [#list parserData.scanAheadExpansions as expansion]
        [@BuildScanRoutine expansion, expansion.maxScanAhead /]
   [/#list]
   [#list grammar.allLookaheads as lookahead]
[#--       ${firstSetVar(lookahead)} --]
      [#if lookahead.nestedExpansion??]
       [@BuildLookaheadRoutine lookahead /]
     [/#if]
   [/#list]

   [#list grammar.allLookBehinds as lookBehind]
      [@BuildLookBehindRoutine lookBehind /]
   [/#list]
[/#macro]   

[#macro firstSetVars]
    //=================================
     // EnumSets that represent the various expansions' first set (i.e. the set of tokens with which the expansion can begin)
     //=================================
    [#list grammar.expansionsForFirstSet as expansion]
          [@firstSetVar expansion/]
    [/#list]

[/#macro]

[#macro finalSetVars]
    //=================================
     // EnumSets that represent the various expansions' final set (i.e. the set of tokens with which the expansion can end)
     //=================================
    [#list grammar.expansionsForFinalSet as expansion]
          [@finalSetVar expansion/]
    [/#list]
[/#macro]


[#macro followSetVars]
    //=================================
     // EnumSets that represent the various expansions' follow set (i.e. the set of tokens that can immediately follow this)
     //=================================
    [#list grammar.expansionsForFollowSet as expansion]
          [@followSetVar expansion/]
    [/#list]
[/#macro]

[#macro firstSetVar expansion]
    [@enumSet expansion.firstSetVarName expansion.firstSet.tokenNames /]
[/#macro]

[#macro finalSetVar expansion]
    [@enumSet expansion.finalSetVarName expansion.finalSet.tokenNames /]
[/#macro]            

[#macro followSetVar expansion]
    [@enumSet expansion.followSetVarName expansion.followSet.tokenNames/]
[/#macro]            

[#macro enumSet varName tokenNames]
   [#if tokenNames?size=0]
       static private final EnumSet<TokenType> ${varName} = EnumSet.noneOf(TokenType.class);
   [#else]
       static private final EnumSet<TokenType> ${varName} = EnumSet.of(
       [#list tokenNames as type]
          [#if type_index > 0],[/#if]
          TokenType.${type} 
       [/#list]
     ); 
   [/#if]
[/#macro]

[#macro ParserProduction production]
    [@firstSetVar production.expansion/]
    [#if grammar.options.faultTolerant]
      [@finalSetVar production.expansion/]
    [/#if]
    ${production.leadingComments}
// ${production.inputSource}, line ${production.beginLine}
    final ${production.accessMod!"public"} 
    ${production.returnType!"void"}
    ${production.name}(${production.parameterList!}) 
    throws ParseException
    [#list (production.throwsList.types)! as throw], ${throw}[/#list] {
     if (trace_enabled) LOGGER.info("Entering production defined on line ${production.beginLine} of ${production.inputSource}");
     if (cancelled) throw new CancellationException();
   [@BuildCode production.expansion /]
    }   
[/#macro]

[#macro BuildCode expansion]
   [#if expansion.simpleName != "ExpansionSequence"]
  // Code for ${expansion.simpleName} specified on line ${expansion.beginLine} of ${expansion.inputSource}
  [/#if]
    [#var forced=expansion.forced, nodeVarName, parseExceptionVar, production, treeNodeBehavior, buildTreeNode=false, forcedVarName, closeCondition = "true", callStackSizeVar]
    [#set treeNodeBehavior = expansion.treeNodeBehavior]
    [#if expansion.parent.simpleName = "BNFProduction"]
      [#set production = expansion.parent]
      [#set forced = production.forced || forced]
    [/#if]
    [#if grammar.options.treeBuildingEnabled]
      [#set buildTreeNode = (treeNodeBehavior?is_null && production?? && !grammar.options.nodeDefaultVoid)
                        || (treeNodeBehavior?? && !treeNodeBehavior.void)]
    [/#if]
    [#if buildTreeNode]
        [@setupTreeVariables .scope /]
        [#if grammar.options.faultTolerant]
         [#if forced]
              boolean ${forcedVarName} = this.tolerantParsing;
          [#else]
              boolean ${forcedVarName} = this.tolerantParsing && currentNTForced;
          [/#if]
        [#else]
        boolean ${forcedVarName} = false;
        [/#if]
      [@createNode treeNodeBehavior nodeVarName /]
          ParseException ${parseExceptionVar} = null;
          [#set newVarIndex = newVarIndex +1]
          [#set callStackSizeVar = "callStackSize" + newVarIndex]
          int ${callStackSizeVar} = parsingStack.size();
         try {
    [/#if]
        ${(production.javaCode)!}
        [@BuildExpansionCode expansion/]
    [#var returnType = (production.returnType)!"void"]
    [#if production?? && returnType == "void"]
        if (trace_enabled) LOGGER.info("Exiting normally from ${production.name}");
    [/#if]
    [#if buildTreeNode]
         }
         catch (ParseException e) { 
             ${parseExceptionVar} = e;
      [#if !grammar.options.faultTolerant]
             throw e;
      [#else]             
             if (trace_enabled) LOGGER.info("We have a parse error but are in in fault-tolerant mode, so we try to handle it.");
          [#if production?? && returnType == production.nodeName]
             [#-- We just assume that if the return type is the same as the type of the node, we want to return CURRENT_NODE.
                   This is not theoretically correct, but will probably be true about 99% of the time. Maybe REVISIT. --]
              return ${nodeVarName};
          
             [#-- This is a bit screwy will not work if the return type is a primitive type --]
              return null;
          [/#if]
[/#if]	
         }
         finally {
             if (${parseExceptionVar} == null) {
                restoreCallStack(${callStackSizeVar});
             }
[#if !grammar.options.faultTolerant]
             if (buildTree) {
                 if (${parseExceptionVar} == null) {
                     closeNodeScope(${nodeVarName}, ${closeCondition});
                 } else {
                     if (trace_enabled) LOGGER.warning("ParseException: " + ${parseExceptionVar}.getMessage());
                     clearNodeScope();
                 }
             }
[#else]
             if (buildTree) {
                 if (${parseExceptionVar} == null) {
                     closeNodeScope(${nodeVarName}, ${closeCondition});
                 }
                else {
                     if (trace_enabled) LOGGER.warning("ParseException ${parseExceptionVar}: " + ${parseExceptionVar}.getMessage());
                    ${nodeVarName}.setParseException(${parseExceptionVar});
                     if (${forcedVarName}) { 
                        restoreCallStack(${callStackSizeVar});
                        Token virtualToken = insertVirtualToken(TokenType.${expansion.finalSet.firstTokenName}); 
                        resetNextToken();
                        if (tokensAreNodes) {
                            currentNodeScope.add(virtualToken);
                        } 
                        String message = "Inserted virtual token of type " + virtualToken.getType()
                                                  +"\non line " + virtualToken.getBeginLine()
                                                  + ", column " + virtualToken.getBeginColumn()
                                                   + " of " + token_source.getInputSource()
                                                  +"\n to complete expansion in ${currentProduction.name}\n";
                        message += ${parseExceptionVar}.getMessage(); 
                        addParsingProblem(new ParsingProblem(message, ${nodeVarName})); 
                      closeNodeScope(${nodeVarName}, true); 
                   } else {
                        closeNodeScope(${nodeVarName}, false);
                        if (trace_enabled) LOGGER.info("Rethrowing " + "${parseExceptionVar}");
                      throw ${parseExceptionVar};
                   }
                }
        }
[/#if]  
         }       
          ${grammar.utils.popNodeVariableName()!}
    [/#if]
[/#macro]

[#--  A helper macro to set up some variables so that the BuildCode macro can be a bit more readable --]
[#macro setupTreeVariables callingScope]
    [#set nodeNumbering = nodeNumbering +1]
    [#set nodeVarName = currentProduction.name + nodeNumbering in callingScope]
    [#set forcedVarName = callingScope.nodeVarName+"forced" in callingScope]
    ${grammar.utils.pushNodeVariableName(callingScope.nodeVarName)!}
    [#set parseExceptionVar = "parseException"+nodeNumbering in callingScope]
    [#if !callingScope.treeNodeBehavior??]
        [#if grammar.options.smartNodeCreation]
           [#set treeNodeBehavior = {"name" : callingScope.production.name, "condition" : "1", "gtNode" : true, "void" :false} in callingScope]
        [#else]
           [#set treeNodeBehavior = {"name" : callingScope.production.name, "condition" : null, "gtNode" : false, "void" : false} in callingScope]
        [/#if]
     [/#if]
     [#if callingScope.treeNodeBehavior.condition?has_content]
       [#set closeCondition = callingScope.treeNodeBehavior.condition in callingScope]
       [#if callingScope.treeNodeBehavior.gtNode]
          [#set closeCondition = "nodeArity() > " + callingScope.closeCondition in callingScope]
       [/#if]
    [/#if]
[/#macro]

[#--  Boilerplate code to create the node variable --]
[#macro createNode treeNodeBehavior nodeVarName]
   [#var nodeName = NODE_PREFIX + currentProduction.name]
   [#if treeNodeBehavior?? && treeNodeBehavior.nodeName??]
      [#set nodeName = NODE_PREFIX + treeNodeBehavior.nodeName]
   [/#if]
   ${nodeName} ${nodeVarName} = null;
   if (buildTree) {
   [#if NODE_USES_PARSER]
        ${nodeVarName} = new ${nodeName}(this);
   [#else]
       ${nodeVarName} = new ${nodeName}();
   [/#if]
       openNodeScope(${nodeVarName});
  }
[/#macro]


[#macro BuildExpansionCode expansion]
    [#var classname=expansion.simpleName]
    [#if classname = "CodeBlock"]
       ${expansion}
    [#elseif classname = "ExpansionSequence"]
       [@BuildCodeSequence expansion/]
    [#elseif classname = "NonTerminal"]
       [@BuildCodeNonTerminal expansion/]
    [#elseif expansion.isRegexp]
       [@BuildCodeRegexp expansion/]
    [#elseif classname = "TryBlock"]
       [@BuildCodeTryBlock expansion/]
    [#elseif classname = "AttemptBlock"]
       [@BuildCodeAttemptBlock expansion /]
    [#elseif classname = "ZeroOrOne"]
       [@BuildCodeZeroOrOne expansion/]
    [#elseif classname = "ZeroOrMore"]
       [@BuildCodeZeroOrMore expansion/]
    [#elseif classname = "OneOrMore"]
        [@BuildCodeOneOrMore expansion/]
    [#elseif classname = "ExpansionChoice"]
        [@BuildCodeChoice expansion/]
    [/#if]
[/#macro]

[#macro BuildCodeSequence expansion]
       [#list expansion.units as subexp]
           [@BuildCode subexp/]
       [/#list]        
[/#macro]

[#macro BuildCodeRegexp regexp]
       [#if regexp.LHS??]
          ${regexp.LHS} =  
       [/#if]
  [#if !grammar.options.faultTolerant]       
       consumeToken(TokenType.${regexp.label});
   [#else]
        consumeToken(TokenType.${regexp.label}, ${regexp.forced?string("true", "false")});
   [/#if]
[/#macro]

[#macro BuildCodeTryBlock tryblock]
   [#var nested=tryblock.nestedExpansion]
       try {
          [@BuildCode nested/]
       }
   [#list tryblock.catchBlocks as catchBlock]
       ${catchBlock}
   [/#list]
       ${tryblock.finallyBlock!}
[/#macro]


[#macro BuildCodeAttemptBlock attemptBlock]
   [#var nested=attemptBlock.nestedExpansion]
       try {
          stashParseState();
          [@BuildCode nested/]
          popParseState();
       }
       catch (ParseException e) {
           restoreStashedParseState();
           [#if attemptBlock.recoveryCode??]
              ${attemptBlock.recoveryCode}
           [/#if]
           [#if attemptBlock.recoveryExpansion??]
               [@BuildCode attemptBlock.recoveryExpansion /]
           [#else]
               if (false) throw new ParseException("Never happens!");
           [/#if]
       }
[/#macro]

[#macro BuildCodeNonTerminal nonterminal]
   pushOntoCallStack("${nonterminal.containingProduction.name}", "${nonterminal.inputSource}", ${nonterminal.beginLine}, ${nonterminal.beginColumn}); 
   [#if grammar.options.faultTolerant && !nonterminal.production.forced]
     [@newVar type="boolean" init="currentNTForced"/]
    currentNTForced = ${nonterminal.forced?string("true", "false")};
   [/#if]
   try {
   [#if !nonterminal.LHS??]
       ${nonterminal.name}(${nonterminal.args!});
   [#else]
       ${nonterminal.LHS} = ${nonterminal.name}(${nonterminal.args!});
    [/#if]
    } finally {
        popCallStack();
    [#if grammar.options.faultTolerant && !nonterminal.production.forced]
        currentNTForced = boolean${newVarIndex};
    [/#if]
    }
[/#macro]


[#macro BuildCodeZeroOrOne zoo]
    [#if zoo.nestedExpansion.alwaysSuccessful
      || zoo.nestedExpansion.class.simpleName = "ExpansionChoice"]
       [@BuildCode zoo.nestedExpansion /]
    [#else]
       if (${ResetCall(zoo)} && ${ExpansionCondition(zoo)}) {
          ${BuildCode(zoo.nestedExpansion)}
       }
    [/#if]
[/#macro]

[#var inFirstVarName = "", inFirstIndex =0]

[#macro BuildCodeOneOrMore oom]
   [#var nestedExp=oom.nestedExpansion, prevInFirstVarName = inFirstVarName/]
   [#if nestedExp.simpleName = "ExpansionChoice"]
     [#set inFirstVarName = "inFirst" + inFirstIndex, inFirstIndex = inFirstIndex +1 /]
     boolean ${inFirstVarName} = true; 
   [/#if]
   do {
      [@BuildCode nestedExp/]
      [#if nestedExp.simpleName = "ExpansionChoice"]
         ${inFirstVarName} = false;
      [/#if]
   } 
   [#if nestedExp.simpleName = "ExpansionChoice"]
   while (true);
   [#else]
   while(${ResetCall(nestedExp)} && ${ExpansionCondition(oom)});
   [/#if]
   [#set inFirstVarName = prevInFirstVarName /]
[/#macro]

[#macro BuildCodeZeroOrMore zom]
    [#if zom.nestedExpansion.class.simpleName = "ExpansionChoice"]
       while (true) {
    [#else]
      while (${ResetCall(zom)} && ${ExpansionCondition(zom)}) {
    [/#if]
       ${BuildCode(zom.nestedExpansion)}
    }
[/#macro]

[#macro BuildCodeChoice choice]
   [#list choice.choices as expansion]
      [#if expansion.alwaysSuccessful]
         else {
           [@BuildCode expansion /]
         }
         [#return]
      [/#if]
      ${(expansion_index=0)?string("if", "else if")}
      (${ResetCall(expansion)} && ${ExpansionCondition(expansion)}) {
         ${BuildCode(expansion)}
      }
   [/#list]
   [#if choice.parent.simpleName == "ZeroOrMore"]
      else {
         break;
      }
   [#elseif choice.parent.simpleName = "OneOrMore"]
       else if (${inFirstVarName}) {
           pushOntoCallStack("${currentProduction.name}", "${choice.inputSource}", ${choice.beginLine}, ${choice.beginColumn});
           throw new ParseException(current_token.getNext(), ${choice.firstSetVarName}, parsingStack);
       } else {
           break;
       }
   [#elseif choice.parent.simpleName != "ZeroOrOne"]
       else {
           pushOntoCallStack("${currentProduction.name}", "${choice.inputSource}", ${choice.beginLine}, ${choice.beginColumn});
           throw new ParseException(current_token.getNext(), ${choice.firstSetVarName}, parsingStack);
        }
   [/#if]
[/#macro]

[#macro ResetCall expansion]
    [#if !expansion.upToExpansion??]
       resetScanAhead(${expansion.lookaheadAmount})
    [#else]
       [#var firstSet = expansion.upToExpansion.firstSet.tokenNames]
       [#if firstSet?size = 1]
           resetScanAhead(${expansion.lookaheadAmount}, TokenType.${firstSet[0]})
       [#else]
           resetScanAhead(${expansion.lookaheadAmount}, ${expansion.upToExpansion.firstSetVarName})
       [/#if]
     [/#if]
[/#macro]

[#-- 
     Macro to generate the condition for entering an expansion
     including the default single-token lookahead
--]
[#macro ExpansionCondition expansion]
   [#var empty = true]
   [#if expansion.lookahead?? && expansion.lookahead.LHS??]
      (${expansion.lookahead.LHS} =
   [/#if]
   [#if expansion.hasSemanticLookahead]
      (${expansion.semanticLookahead}) 
      [#set empty = false]
   [/#if]
   [#if expansion.hasLookBehind]
      [#if !empty] && [/#if]
      [#set empty = false]
      ${expansion.lookBehind.routineName}() 
   [/#if]
   [#if expansion.requiresScanAhead]
      [#if !empty] && [/#if]
      [#set empty = false]
      [#if expansion.negated]![/#if]
      [#if expansion.lookaheadExpansion.singleToken]
      (${SingleTokenCondition(expansion.lookaheadExpansion)})
      [#else]
      ${expansion.lookaheadExpansion.scanRoutineName}()
      [/#if]
   [/#if]
   [#if empty]
      ${SingleTokenCondition(expansion)}
   [/#if]
   [#if expansion.lookahead?? && expansion.lookahead.LHS??]
      )
   [/#if]
[/#macro]

[#macro SingleTokenCondition expansion]
   [#if expansion.firstSet.tokenNames?size < 5] 
      [#list expansion.firstSet.tokenNames as name]
          nextTokenType == TokenType.${name} 
         [#if name_has_next] || [/#if] 
      [/#list]
   [#else]
      ${expansion.firstSetVarName}.contains(nextTokenType) 
   [/#if]
[/#macro]

[#var parserData=grammar.parserData]
[#var nodeNumbering = 0]
[#var NODE_USES_PARSER = grammar.options.nodeUsesParser]
[#var NODE_PREFIX = grammar.options.nodePrefix]
[#var currentProduction]


[#--
   Generates the routine for an explicit lookahead
   that is used in a nested lookahead.
 --]
[#macro BuildLookaheadRoutine lookahead]
  [#if lookahead.nestedExpansion??]
     private final boolean ${lookahead.routineName}() {
        int prevRemainingLookahead = remainingLookahead;
        Token prevScanAheadToken = currentLookaheadToken;
        try {
          [@BuildScanCode lookahead.nestedExpansion/]
          return true;
        }
        finally {
           currentLookaheadToken = prevScanAheadToken;
           remainingLookahead = prevRemainingLookahead;
        }
     }
   [/#if]
[/#macro]

[#macro BuildLookBehindRoutine lookBehind]
    private final boolean ${lookBehind.routineName}() {
       Iterator<NonTerminalCall> stackIterator = ${lookBehind.backward?string("stackIteratorBackward", "stackIteratorForward")}();
       boolean foundProduction = false;
       [#var justSawEllipsis = false]
       [#list lookBehind.path as element]
          [#var elementNegated = (element[0] == "~")]
          [#if elementNegated][#set element = element[1..]][/#if]
          [#if element == "..."]
             [#set justSawEllipsis = true]
          [#elseif element = "."]
             [#set justSawEllipsis = false]
             if (!stackIterator.hasNext()) {
                return ${bool(lookBehind.negated)};
             }
             stackIterator.next();
         [#else]
             [#var exclam = elementNegated?string("!", "")]
             [#if justSawEllipsis]
               foundProduction = false;
               while (stackIterator.hasNext() && !foundProduction) {
                  NonTerminalCall ntc = stackIterator.next();
                  if (${exclam}ntc.productionName.equals("${element}")) {
                     foundProduction = true;
                  }
               }
               if (!foundProduction) {
                  return ${bool(lookBehind.negated)};
               }
           [#else]
               [#var exclam = elementNegated?string("", "!")]
               if (!stackIterator.hasNext()) {
                  return ${bool(lookBehind.negated)};
               } else {
                  NonTerminalCall ntc = stackIterator.next();
                  if (${exclam}ntc.productionName.equals("${element}")) {
                     return ${bool(lookBehind.negated)};
                  }
               }
           [/#if]
           [#set justSawEllipsis = false] 
         [/#if]
       [/#list]
       [#if lookBehind.hasEndingSlash]
           return [#if !lookBehind.negated]![/#if]stackIterator.hasNext();
       [#else]
           return ${bool(!lookBehind.negated)};
       [/#if]
    }
[/#macro]


[#macro BuildScanRoutine expansion count]
     private final boolean ${expansion.scanRoutineName}() {
     if (remainingLookahead <=0) return true;
     [#if expansion.parent.class.simpleName = "BNFProduction"]
       [#if expansion.parent.javaCode?? && expansion.parent.javaCode.appliesInLookahead]
          ${expansion.parent.javaCode}
       [/#if]
     [/#if]
      [@BuildScanCode expansion, count/]
      return true;
    }
[/#macro]



[#--
   Macro to build the lookahead code for an expansion.
   This macro just delegates to the various sub-macros
   based on the Expansion's class name.
--]
[#macro BuildScanCode expansion count=2147483647]
  [#if expansion.singleToken]
    [#var firstSet = expansion.firstSet.tokenNames]
    [#if firstSet?size = 1]
      if (!scanToken(TokenType.${firstSet[0]})) return false;
    [#else]
      if (!scanToken(${expansion.firstSetVarName})) return false;
    [/#if]
    [#return]
  [/#if]
  [#var classname=expansion.simpleName]
    [#if expansion.isRegexp]
      [@ScanCodeRegexp expansion/]
   [#elseif classname = "ExpansionSequence"]
      [@ScanCodeSequence expansion count/]
   [#elseif classname = "ZeroOrOne"]
      [@ScanCodeZeroOrOne expansion/]
   [#elseif classname = "ZeroOrMore"]
      [@ScanCodeZeroOrMore expansion/]
   [#elseif classname = "OneOrMore"]
      [@ScanCodeOneOrMore expansion/]
   [#elseif classname = "NonTerminal"]
      [@ScanCodeNonTerminal expansion/]
   [#elseif classname = "TryBlock" || classname="AttemptBlock"]
      [@BuildScanCode expansion.nestedExpansion, count/]
   [#elseif classname = "ExpansionChoice"]
      [@ScanCodeChoice expansion /]
   [#elseif classname = "CodeBlock"]
      [#if expansion.appliesInLookahead]
      ${expansion}
      [/#if]
  [/#if]
[/#macro]

[#macro ScanCodeChoice choice]
   [@newVar "Token", "currentLookaheadToken"/]
   int remainingLookahead${newVarIndex} = remainingLookahead;
  [#list choice.choices as subseq]
     if (!([@InvokeScanRoutine subseq/])) {
     [#if subseq_has_next]
        currentLookaheadToken = token${newVarIndex};
        remainingLookahead = remainingLookahead${newVarIndex};
     [#else]
        return false;
     [/#if]
  [/#list]
  [#list 1..choice.choices?size as unused] } [/#list]
[/#macro]

[#macro ScanCodeRegexp regexp]
     if (!scanToken(TokenType.${regexp.label})) return false;
[/#macro]

[#macro ScanCodeZeroOrOne zoo]
   [@newVar type="Token" init="currentLookaheadToken"/]
   if (!([@InvokeScanRoutine zoo.nestedExpansion/])) 
      currentLookaheadToken = token${newVarIndex};
[/#macro]

[#-- 
  Generates lookahead code for a ZeroOrMore construct]
--]
[#macro ScanCodeZeroOrMore zom]
      while (remainingLookahead > 0) {
      [@newVar type="Token" init="currentLookaheadToken"/]
         if (!(
         [@InvokeScanRoutine zom.nestedExpansion/])) {
             currentLookaheadToken = token${newVarIndex};
             break;
         }
      }
[/#macro]

[#--
   Generates lookahead code for a OneOrMore construct
   It generates the code for checking a single occurrence
   and then the same code as a ZeroOrMore
--]
[#macro ScanCodeOneOrMore oom]
   if (!([@InvokeScanRoutine oom.nestedExpansion/])) return false;
   [@ScanCodeZeroOrMore oom /]
[/#macro]

[#--
  Generates the lookahead code for a non-terminal.
  It (trivially) just delegates to the code for 
  checking the production's nested expansion 
--]
[#macro ScanCodeNonTerminal nt]
      pushOntoLookaheadStack("${nt.containingProduction.name}", "${nt.inputSource}", ${nt.beginLine}, ${nt.beginColumn});
      if (![@InvokeScanRoutine nt.production.expansion/]) {
         popLookaheadStack();
         return false;
      }
      popLookaheadStack();
[/#macro]

[#--
   Generates the lookahead code for an ExpansionSequence
   The count parameter is the maximum number of tokens that 
   we need to lookahead, so, if it is clear that we don't
   need to generate code beyond the nth expnasion, we just
   break out. (This is a peephole space optimization that may
   not be worth the candle. REVISIT later.)
--]
[#macro ScanCodeSequence sequence, count]
   [#list sequence.units as sub]
       [@BuildScanCode sub, count/]
       [#set count = count - sub.minimumSize]
       [#if count<=0][#break][/#if]
   [/#list]
[/#macro]

[#-- 
  Invoke the code for scanning for an expansion.
  If the expansion has an explicit (nested) lookahead, it checks for 
  the lookahead succeeding and then the expansion itself.
--]
[#macro InvokeScanRoutine expansion]
   [#if expansion.lookahead?? && expansion.lookahead.semanticLookaheadNested]
       (${expansion.semanticLookahead}) &&
   [/#if]
   [#if expansion.hasLookBehind]
       ${expansion.lookBehind.routineName}() &&
   [/#if]
   [#if expansion.hasSyntacticLookahead]
            ${expansion.negated?string("!", "")}${expansion.lookahead.routineName}() &&
   [/#if]
   [#if expansion.singleToken]
       [#var firstSet = expansion.firstSet.tokenNames]
       [#if firstSet?size ==1]
         scanToken(TokenType.${firstSet[0]})
       [#else]
         scanToken(${expansion.firstSetVarName})
       [/#if]
   [#else]
      ${expansion.scanRoutineName}()
   [/#if]
[/#macro]

[#var newVarIndex=0]
[#-- Just to generate a new unique variable name
  All it does is tack an integer (that is incremented)
  onto the type name, and optionally initializes it to some value--]
[#macro newVar type init=null]
   [#set newVarIndex = newVarIndex+1]
   ${type} ${type?lower_case}${newVarIndex}
   [#if init??]
      = ${init}
   [/#if]
   ;
[/#macro]   


[#-- A macro to use at one's convenience to comment out a block of code --]
[#macro comment]
[#var content, lines]
[#set content][#nested/][/#set]
[#set lines = content?split("\n")]
[#list lines as line]
// ${line}
[/#list]
[/#macro]

[#function bool val]
   [#return val?string("true", "false")/]
[/#function]