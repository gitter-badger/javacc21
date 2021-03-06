/* Generated by: ${generated_by}. ${filename} */
[#if grammar.parserPackage?has_content]
package ${grammar.parserPackage};
[/#if]
import java.util.*;
[#if grammar.nodePackage?has_content && grammar.nodePackage != grammar.parserPackage]
import ${grammar.nodePackage}.*;
[/#if]

[#if grammar.options.freemarkerNodes]
import freemarker.template.*;
[/#if]

 [#var extendsNode = ""]
 
 [#if grammar.options.treeBuildingEnabled]
    [#set extendsNode =", Node"]
 [/#if]
 
public class Token implements ${grammar.constantsClassName} ${extendsNode} {


 [#if !grammar.options.hugeFileSupport && !grammar.options.userDefinedLexer]
 
    private FileLineMap fileLineMap; 
    
    public FileLineMap getFileLineMap() {
        [#if grammar.options.treeBuildingEnabled]
        if (fileLineMap == null) {
           Node n = getParent();
           while (n!= null) {
               fileLineMap = n.getFileLineMap();
               if (fileLineMap != null) break;
               n = n.getParent();
            }
        }
        [/#if]
        return fileLineMap;
    }
    

    public Token(TokenType type, String image, FileLineMap fileLineMap) {
        this.type = type;
        this.image = image;
        this.fileLineMap = fileLineMap;
    }
    
    public void setInputSource(FileLineMap fileLineMap) {
        this.fileLineMap = fileLineMap;
    }
    
    [#if !grammar.options.treeBuildingEnabled]
    public String getInputSource() {
        return inputSource;
     }
     
     public String getSource() {
         return getFileLineMap().getText(beginLine, beginColumn, endLine, endColumn);
     }
    [/#if]    
    
     
  [#else]   
    public void setInputSource(String inputSource) {
        this.inputSource = inputSource;
    }
    
    public String getInputSource() {
        return inputSource;
     }
 [/#if]          

 

[#if grammar.options.faultTolerant]

   // The token does not correspond to actual characters in the input.
   // It was typically inserted to (tolerantly) complete some grammatical production.
   private boolean virtual;
   
   public boolean isVirtual() {
      return virtual;
   }
   
   public void setVirtual(boolean virtual) {this.virtual = virtual;}
   
[/#if]


    private String inputSource = "";

    private TokenType type;
    
    public TokenType getType() {
        return type;
    }
    
    void setType(TokenType type) {
        this.type=type;
    }
    
    /**
     * beginLine and beginColumn describe the position of the first character
     * of this token; endLine and endColumn describe the position of the
     * last character of this token.
     */
[#if !grammar.options.legacyAPI]private[/#if]      
    int beginLine, beginColumn, endLine, endColumn;

    /**
     * The string image of the token.
     */
[#if !grammar.options.legacyAPI]private[/#if]      
    String image;
    
    public String getImage() {
[#if !grammar.options.hugeFileSupport && !grammar.options.userDefinedLexer]    
        if (image == null) {
            return getSource();
        } 
[/#if]        
        return image;
    }
    
   public void setImage(String image) {
       this.image = image;
   } 
    
[#if !grammar.options.userDefinedLexer && grammar.lexerData.tokenCount>1]
    private LexicalState lexicalState;
        
    void setLexicalState(LexicalState state) {
        this.lexicalState = state;
    }
    
    LexicalState getLexicalState() {
        return lexicalState;
    }
[/#if]

[#if grammar.options.legacyAPI]

    void setKind(int kind) {
        this.type = TokenType.values()[kind];
    }
    
    int getKind() {
        return type.ordinal();
    }

    /**
     * A reference to the next regular (non-special) token from the input
     * stream.  If this is the last token from the input stream, or if the
     * token manager has not read tokens beyond this one, this field is
     * set to null.  This is true only if this token is also a regular
     * token.  Otherwise, see below for a description of the contents of
     * this field.
     */
[#else]
    private
[/#if]
   Token next;
    
    Token getNext() {
       return next;
    }
    
    void setNext(Token next) {
        this.next = next;
    }

    /**
     * This field is used to access special tokens that occur prior to this
     * token, but after the immediately preceding regular (non-special) token.
     * If there are no such special tokens, this field is set to null.
     * When there are more than one such special token, this field refers
     * to the last of these special tokens, which in turn refers to the next
     * previous special token through its specialToken field, and so on
     * until the first special token (whose specialToken field is null).
     * The next fields of special tokens refer to other special tokens that
     * immediately follow it (without an intervening regular token).  If there
     * is no such token, this field is null.
     */
[#if !grammar.options.legacyAPI]private[/#if]     
    Token specialToken;
    
    public Token getSpecialToken() {
         return specialToken;
    }
    
    public void setSpecialToken(Token specialToken) {
         this.specialToken = specialToken;
    }
    
    private boolean unparsed;

    //Should find a way to get rid of this.
    Token() {} 
    
    
    public Token(int kind) {
       this(kind, null);
       this.type = TokenType.values()[kind];
    }

    /**
     * Constructs a new token for the specified Image and Kind.
     */
    public Token(int kind, String image) {
        this.type = TokenType.values()[kind];
        this.image = image;;
    }
    
    public Token(TokenType type, String image, String inputSource) {
        this.type = type;
        this.image = image;
        this.inputSource = inputSource;
    }
    
   public boolean isUnparsed() {
        return unparsed;
    }
    
    public void setUnparsed(boolean unparsed) {
        this.unparsed = unparsed;
    }

    /** 
     * Utility method to merge two tokens into a single token of a given type.
     */
    static Token merge(Token t1, Token t2, TokenType type) {
        Token merged = new Token(type, t1.getImage() + t2.getImage(), t1.getInputSource());
        merged.setBeginLine(t1.getBeginLine());
        merged.setBeginColumn(t1.getBeginColumn());
        merged.setEndColumn(t2.getEndColumn());
        merged.setEndLine(t2.getEndLine());
        merged.setNext(t2.getNext());
        return merged;
    }

    /**
     * Utility method to split a token in 2. For now, it assumes that the token 
     * is all on a single line. (Will maybe fix that later). Returns the first token.
     */ 
    static Token split(Token tok, int length, TokenType type1, TokenType type2) {
        String img1 = tok.getImage().substring(0, length);
        String img2 = tok.getImage().substring(length);
        Token t1 = new Token(type1, img1, tok.getInputSource());
        Token t2 = new Token(type2, img2, tok.getInputSource());
        t1.setBeginColumn(tok.getBeginColumn());
        t1.setEndColumn(tok.getBeginColumn() + length -1);
        t1.setBeginLine(tok.getBeginLine());
        t1.setEndLine(tok.getBeginLine());
        t2.setBeginColumn(t1.getEndColumn() +1);
        t2.setEndColumn(tok.getEndColumn());
        t2.setBeginLine(tok.getBeginLine());
        t2.setEndLine(tok.getEndLine());
        t1.setNext(t2);
        t2.setNext(tok.getNext());
        return t1;
    }
    
    public void clearChildren() {}
    
    public String getNormalizedText() {
[#if grammar.options.faultTolerant]
        if (virtual) {
             return "Virtual Token of type " + getType();
        }
[/#if]    
        if (getType() == TokenType.EOF) {
            return "EOF";
        }
        return getImage();
    }
    
    public String toString() {
        return getNormalizedText();
    }
[#if grammar.options.legacyAPI]    
    public static Token newToken(int ofKind, String image) {
       [#if grammar.options.treeBuildingEnabled]
           switch(ofKind) {
           [#list grammar.orderedNamedTokens as re]
            [#if re.generatedClassName != "Token" && !re.private]
              case ${re.label} : return new ${re.generatedClassName}(ofKind, image);
            [/#if]
           [/#list]
              default: return new Token(ofKind, image);
           }
       [#else]
       return new Token(ofKind, image); 
       [/#if]
    }
[/#if]    
[#if grammar.options.hugeFileSupport]    
    public static Token newToken(TokenType type, String image, String inputSource) {
           [#if !grammar.options.hugeFileSupport]image = null;[/#if]
           [#if grammar.options.treeBuildingEnabled]
           switch(type) {
           [#list grammar.orderedNamedTokens as re]
            [#if re.generatedClassName != "Token" && !re.private]
              case ${re.label} : return new ${re.generatedClassName}(TokenType.${re.label}, image, inputSource);
            [/#if]
           [/#list]
           default : return new Token(type, image, inputSource);
           }
       [#else]
         return new Token(type, image, inputSource);      
       [/#if]
    }
    
[#else]
   [#if !grammar.options.userDefinedLexer]    
    public static Token newToken(TokenType type, String image, FileLineMap fileLineMap) {
           [#--  if !grammar.options.hugeFileSupport]image = null;[/#if --]
           [#if grammar.options.treeBuildingEnabled]
           switch(type) {
           [#list grammar.orderedNamedTokens as re]
            [#if re.generatedClassName != "Token" && !re.private]
              case ${re.label} : return new ${re.generatedClassName}(TokenType.${re.label}, image, fileLineMap);
            [/#if]
           [/#list]
              default :        return new Token(type, image, fileLineMap);      

           }
       [#else]
          return new Token(type, image, fileLineMap);      
       [/#if]
    }
[#if grammar.productionTable?size != 0]    
    public static Token newToken(TokenType type, String image, ${grammar.parserClassName} parser) {
        return newToken(type, image, parser.token_source);
    } 
[/#if]    
    public static Token newToken(TokenType type, String image, ${grammar.lexerClassName} lexer) {
        return newToken(type, image, lexer.input_stream);
    }
    [/#if]
    
  [#if grammar.options.treeBuildingEnabled && !grammar.options.userDefinedLexer]    
    public static Token newToken(TokenType type, String image, Node node) {
        return newToken(type, image, node.getFileLineMap());
    }
  [/#if]
     
[/#if]    
    
    
    public void setBeginColumn(int beginColumn) {
        this.beginColumn = beginColumn;
    }	
    
    public void setEndColumn(int endColumn) {
        this.endColumn = endColumn;
    }	
    
    public void setBeginLine(int beginLine) {
        this.beginLine = beginLine;
    }	
    
    public void setEndLine(int endLine) {
        this.endLine = endLine;
    }	
    
    public int getBeginLine() {
        return beginLine;
    }
    
    public int getBeginColumn() {
        return beginColumn;
    }
    
    public int getEndLine() {
        return endLine;
    }
    
    public int getEndColumn() {
        return endColumn;
    }
    
    
   
[#if !grammar.options.treeBuildingEnabled]    
    public String getLocation() {
         return "line " + getBeginLine() + ", column " + getBeginColumn() + " of " + getInputSource();
     }
   
[/#if]     
    
[#if grammar.options.treeBuildingEnabled]
    
    private Node parent;
    private Map<String,Object> attributes; 

    public void setChild(int i, Node n) {
        throw new UnsupportedOperationException();
    }

    public void addChild(Node n) {
        throw new UnsupportedOperationException();
    }
    
    public void addChild(int i, Node n) {
        throw new UnsupportedOperationException();
    }
    
    public Node removeChild(int i) {
        throw new UnsupportedOperationException();
    }
    
    public boolean removeChild(Node n) {
        return false;
    }
    
    public int indexOf(Node n) {
        return -1;
    }

    public Node getParent() {
        return parent;
    }

    public void setParent(Node parent) {
        this.parent = parent;
    }
    
    public int getChildCount() {
        return 0;
    }
    
    public Node getChild(int i) {
        return null;
    }
    
    public List<Node> children() {
        return Collections.emptyList();
    }
    
    

    public void open() {}

    public void close() {}
    
    
    public Object getAttribute(String name) {
        return attributes == null ? null : attributes.get(name); 
    }
     
    public void setAttribute(String name, Object value) {
        if (attributes == null) {
            attributes = new HashMap<String, Object>();
        }
        attributes.put(name, value);
    }
     
    public boolean hasAttribute(String name) {
        return attributes == null ? false : attributes.containsKey(name);
    }
     
    public Set<String> getAttributeNames() {
        if (attributes == null) return Collections.emptySet();
        return attributes.keySet();
    }

   [#if grammar.options.freemarkerNodes]
    public TemplateNodeModel getParentNode() {
        return parent;
    }
  
    public TemplateSequenceModel getChildNodes() {
        return null;
    }
  
    public String getNodeName() {
        return getType().toString();
    }
  
    public String getNodeType() {
        return getClass().getSimpleName();
    }
  
    public String getNodeNamespace() {
        return null;
    }
  
    public String getAsString() {
        return getNormalizedText();
    }
[/#if]

 [/#if]

}
