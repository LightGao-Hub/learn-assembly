package com.learn;

import lombok.Builder;
import lombok.Data;

/**
 * Author: GL
 * Date: 2021-06-13
 */
@Builder
@Data
public class CoreUtil {
    private String name;
    private String passwd;
    private String content;
}
