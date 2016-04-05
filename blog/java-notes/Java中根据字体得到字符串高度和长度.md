#Java中根据字体得到字符串高度和长度
```Java
public static void main(String[] args) {    
    Font f = new Font("宋体", Font.BOLD, 12);    
    FontMetrics fm = sun.font.FontDesignMetrics.getMetrics(f);   
    // 高度    
    System.out.println(fm.getHeight());    
    // 单个字符宽度    
    System.out.println(fm.charWidth('A'));    
    // 整个字符串的宽度    
    System.out.println(fm.stringWidth("宋A"));    	
}
```