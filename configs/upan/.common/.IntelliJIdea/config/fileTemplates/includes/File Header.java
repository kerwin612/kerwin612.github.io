#if (${HOUR} > 11)
    #set($timeStr = "下午")
#else
    #set($timeStr = "上午")
#end
/**
 * 
 * Copyright:   Copyright 2007 - ${YEAR} MPR Tech. Co. Ltd. All Rights Reserved.
 * Date:        ${YEAR}年${MONTH}月${DAY}日 ${timeStr}${TIME}
 * Author:      ${USER}
 * Version:     1.0.0.0
 * Description: Initialize
 */
