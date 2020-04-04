[#ftl strict_vars=true]
[#--
/* Copyright (c) 2008-2019 Jonathan Revusky, revusky@javacc.com
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
/* Generated by: ${generated_by}. ${filename} */
[#if grammar.parserPackage?has_content]
package ${grammar.parserPackage};
[/#if]
import java.util.*;
import java.lang.reflect.*;
[#if grammar.options.freemarkerNodes]
import freemarker.template.*;
[/#if]

public interface Node 
[#if grammar.options.freemarkerNodes]
   extends TemplateNodeModel, TemplateScalarModel
[/#if] {

    /** Life-cycle hook method called after the node has been made the current
	 *  node 
	 */
    void open();

  	/** 
  	 * Life-cycle hook method called after all the child nodes have been
     * added. 
     */
    void close();

    
    /**
     * Returns whether this node has any children.
     * 
     * @return Returns <code>true</code> if this node has any children,
     *         <code>false</code> otherwise.
     */
    default boolean hasChildNodes() {
       return getChildCount() > 0;
    }

    void setParent(Node n);
     
    Node getParent();
     
     // The following 9 methods will typically just 
     // delegate straightforwardly to a List object that
     // holds the child nodes
     
     void addChild(Node n);
     
     void addChild(int i, Node n);

     Node getChild(int i);

     void setChild(int i, Node n);
     
     Node removeChild(int i);
     
     boolean removeChild(Node n);
     
     default int indexOf(Node child) {
         for (int i=0; i<getChildCount(); i++) {
             if (child == getChild(i)) {
                 return i;
             }
         }
         return -1;
     }
     
     void clearChildren();
       
     int getChildCount();
     
     /**
      * Most implementations of this should return a copy or
      * an immutable wrapper around the list.
      */
     List<Node> children();
     
     // The following 3 methods will typically delegate
     // straightforwardly to a Map<String, Object> object-s get/set/containsKey/keySet methods.
          
     Object getAttribute(String name);
     
     void setAttribute(String name, Object value);
     
     boolean hasAttribute(String name);
     
     java.util.Set<String> getAttributeNames();
     
     // The following ten methods are for location info.
     
     /**
      * @return A string that says where the input came from. Typically a file name, though
      *         it could be a URL or something else, of course.  
      */
     String getInputSource();
     
     void setInputSource(String inputSource);
      
     int getBeginLine();
     
     int getEndLine();
     
     int getBeginColumn();
     
     int getEndColumn();
     
     void setBeginLine(int beginLine);
     
     void setEndLine(int endLine);
     
     void setBeginColumn(int beginColumn);
     
     void setEndColumn(int endColumn);
     
     default String getLocation() {
         return "line " + getBeginLine() + ", column " + getBeginColumn() + " of " + getInputSource();
     }
     
[#if grammar.options.faultTolerant]
     default boolean isDirty() {
         for (Node child : children()) {
            if (child.isDirty()) return true;
         }
         return false;
     }
[/#if]     
 
[#if grammar.options.visitor] [#--  This thing is just from legacy JJTree. I think the Node.Visitor that uses reflection is more elegant and useful. --]
   [#var RETURN_TYPE = grammar.options.visitorReturnType]
   [#if !RETURN_TYPE?has_content][#set RETURN_TYPE = "void"][/#if]
   [#var DATA_TYPE = grammar.options.visitorDataType]
   [#if !DATA_TYPE?has_content][#set DATA_TYPE="Object"][/#if]
   [#var THROWS = ""]
   [#if grammar.options.visitorException?has_content][#set THROWS = "throws " + grammar.options.visitorException][/#if]
	 ${RETURN_TYPE} jjtAccept(${grammar.parserClassName}Visitor visitor, ${DATA_TYPE} data) ${THROWS};      
[/#if]


   default <T extends Node>T firstChildOfType(Class<T>clazz) {
        for (Node child : children()) {
            if (clazz.isInstance(child)) {
                return clazz.cast(child);
            }
        }
        return null; 
     }
     
     
    default <T extends Node>List<T>childrenOfType(Class<T>clazz) {
        List<T>result=new java.util.ArrayList<>();
        for (Node child : children()) {
            if (clazz.isInstance(child)) {
                result.add(clazz.cast(child));
            }
        }
        return result;
   }
   
   default <T extends Node> List<T> descendantsOfType(Class<T> clazz) {
        List<T> result = new ArrayList<T>();
        for (Node child : children()) {
            if (clazz.isInstance(child)) {
                result.add(clazz.cast(child));
            } 
            result.addAll(child.descendantsOfType(clazz));
        }
        return result;
   }
   
   default <T extends Node> T firstAncestorOfType(Class<T> clazz) {
        Node parent = this;
        while (parent !=null) {
           parent = parent.getParent();
           if (clazz.isInstance(parent)) {
               return clazz.cast(parent);
           }
        }
        return null;
    }
    
    default Node findNodeAt(int line, int column) {
        if (!isIncluded(line, column)) {
            return null;
        }
        for (Node child : children()) {
            Node match = child.findNodeAt(line, column);
            if (match != null) {
                return match;
            }
        }
        return this;
    }
    
    /**
     * Returns true if the given position (line,column) is included in the given
     * node and false otherwise.
     * 
     * @param line   the line position
     * @param column the column position
     * @return true if the given position (line,column) is included in the given
     *         node and false otherwise.
     */
    default boolean isIncluded(int line, int column) {
        return isIncluded(getBeginLine(), getBeginColumn(),getEndLine(), getEndColumn(), line,
                column);
    }

    default boolean isIncluded(int beginLine, int beginColumn, int endLine, int endColumn, int line,
            int column) {
        if (beginLine == line && beginColumn == column) {
            return true;
        }
        if (endLine == line && endColumn == column) {
            return true;
        }            
        return !isAfter(beginLine, beginColumn, line, column) && isAfter(endLine, endColumn, line, column);
    }
    
    /**
     * Returns the first child of this node. If there is no such node, this returns
     * <code>null</code>.
     * 
     * @return the first child of this node. If there is no such node, this returns
     *         <code>null</code>.
     */
    default Node getFirstChild() {
        return getChildCount() > 0 ? getChild(0) : null;
    }
    
    
     /**
     * Returns the last child of the given node. If there is no such node, this
     * returns <code>null</code>.
     * 
     * @return the last child of the given node. If there is no such node, this
     *         returns <code>null</code>.
     */ 
    default Node getLastChild() {
        int count = getChildCount();
        return count>0 ? getChild(count-1): null;
    }


    static boolean isAfter(int line1,int column1,int line2,int column2) {
        if (line1>line2) {
            return true;
        }
        if (line1==line2) {
            return column1>=column2;
        }
        return false;
    }
    
      
    default Node getRoot() {
        Node parent = this;
        while (parent.getParent() != null ) {
            parent = parent.getParent();
        }
        return parent; 
    }
    
     static public List<Token> getTokens(Node node) {
        List<Token> result = new ArrayList<Token>();
        for (Node child : node.children()) {
            if (child instanceof Token) {
                result.add((Token) child);
            } else {
                result.addAll(getTokens(child));
            }
        }
        return result;
    }
        
        
    static public List<Token> getRealTokens(Node n) {
        List<Token> result = new ArrayList<Token>();
		for (Token token : getTokens(n)) {
		    if (!token.isUnparsed()) {
		        result.add(token);
		    }
		}
	    return result;
    }

    default List<Node> descendants(Filter filter) {
       List<Node> result = new ArrayList<>();
       for (Node child : children()) {
          if (filter.accept(child)) {
              result.add(child);
          }
          result.addAll(child.descendants(filter)); 
       }
       return result;
    }
    
    public interface Filter {
       boolean accept(Node node);
    }
    
	static abstract public class Visitor {
		
		static private Method baseVisitMethod;
		private HashMap<Class<? extends Node>, Method> methodCache = new HashMap<>();
		
		static private Method getBaseVisitMethod() throws NoSuchMethodException {
			if (baseVisitMethod == null) {
				baseVisitMethod = Node.Visitor.class.getMethod("visit", new Class[] {Node.class});
			} 
			return baseVisitMethod;
		}
		
		private Method getVisitMethod(Node node) {
			Class<? extends Node> nodeClass = node.getClass();
			if (!methodCache.containsKey(nodeClass)) {
				try {
					Method method = this.getClass().getMethod("visit", new Class[] {nodeClass});
					if (method.equals(getBaseVisitMethod())) {
						method = null; // Have to avoid infinite recursion, no?
					}
					methodCache.put(nodeClass, method);
				}
				catch (NoSuchMethodException nsme) {
					methodCache.put(nodeClass, null);
				}
			}
	        return methodCache.get(nodeClass);
		}
		
		/**
		 * Tries to invoke (via reflection) the appropriate visit(...) method
		 * defined in a subclass. If there is none, it just calls the fallback() routine. 
		 */
		public final void visit(Node node) {
			Method visitMethod = getVisitMethod(node);
			if (visitMethod == null) {
				fallback(node);
			} else try {
				visitMethod.invoke(this, new Object[] {node});
			} catch (InvocationTargetException ite) {
	    		Throwable cause = ite.getCause();
	    		if (cause instanceof RuntimeException) {
	    			throw (RuntimeException) cause;
	    		}
	    		throw new RuntimeException(ite);
	 		} catch (IllegalAccessException iae) {
	 			throw new RuntimeException(iae);
	 		}
		}
		
		/**
		 * If there is no specific method to visit this node type,
		 * it just uses this method. The default base implementation
		 * is just to recurse over the nodes.
		 */
		public void fallback(Node node) {
		    for (Node child : node.children()) {
		        visit(child);
		    }
		}
}
    
}
