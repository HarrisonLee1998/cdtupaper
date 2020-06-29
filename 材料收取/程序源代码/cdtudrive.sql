/*
 Navicat Premium Data Transfer

 Source Server         : 软路由
 Source Server Type    : MySQL
 Source Server Version : 50730
 Source Host           : 192.168.0.102:3306
 Source Schema         : cdtudrive

 Target Server Type    : MySQL
 Target Server Version : 50730
 File Encoding         : 65001

 Date: 19/06/2020 21:41:21
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for department
-- ----------------------------
DROP TABLE IF EXISTS `department`;
CREATE TABLE `department`  (
  `id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `title` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `d_type` int(1) NOT NULL,
  `p_did` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `parent_dept_id`(`p_did`) USING BTREE,
  CONSTRAINT `parent_dept_id` FOREIGN KEY (`p_did`) REFERENCES `department` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for download
-- ----------------------------
DROP TABLE IF EXISTS `download`;
CREATE TABLE `download`  (
  `u_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `fu_id` char(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `download_date` datetime(0) NOT NULL,
  INDEX `donwload_user_id`(`u_id`) USING BTREE,
  INDEX `download_fu_id`(`fu_id`) USING BTREE,
  CONSTRAINT `donwload_user_id` FOREIGN KEY (`u_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `download_fu_id` FOREIGN KEY (`fu_id`) REFERENCES `file_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for file
-- ----------------------------
DROP TABLE IF EXISTS `file`;
CREATE TABLE `file`  (
  `id` char(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `f_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `f_size` bigint(20) UNSIGNED NOT NULL,
  `mime` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `f_type` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `status` int(1) NOT NULL,
  `path` varchar(10240) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `u_date` datetime(0) NOT NULL,
  `u_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_file_id`(`u_id`) USING BTREE,
  CONSTRAINT `user_file_id` FOREIGN KEY (`u_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for file_user
-- ----------------------------
DROP TABLE IF EXISTS `file_user`;
CREATE TABLE `file_user`  (
  `id` char(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `u_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `f_id` char(32) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `f_path` varchar(10240) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `f_name` varchar(256) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `is_folder` int(1) NOT NULL,
  `f_pid` char(32) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `last_update_date` datetime(0) NULL DEFAULT NULL,
  `f_type` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `is_delete` int(1) NULL DEFAULT 0,
  `f_size` bigint(20) UNSIGNED NULL DEFAULT NULL,
  `share_id` char(12) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `g_id` char(12) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `parent_folder`(`f_pid`) USING BTREE,
  INDEX `file_id`(`f_id`) USING BTREE,
  INDEX `file_user_id`(`u_id`) USING BTREE,
  INDEX `fu_share_id`(`share_id`) USING BTREE,
  INDEX `fu_group_id`(`g_id`) USING BTREE,
  CONSTRAINT `file_id` FOREIGN KEY (`f_id`) REFERENCES `file` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `file_user_id` FOREIGN KEY (`u_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fu_group_id` FOREIGN KEY (`g_id`) REFERENCES `group` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fu_share_id` FOREIGN KEY (`share_id`) REFERENCES `share` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `parent_folder` FOREIGN KEY (`f_pid`) REFERENCES `file_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for group
-- ----------------------------
DROP TABLE IF EXISTS `group`;
CREATE TABLE `group`  (
  `id` char(12) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `avatar` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `brief` varchar(1024) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `g_limit` int(1) NULL DEFAULT 0,
  `is_writeable` int(1) NOT NULL,
  `is_readable` int(1) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for group_user
-- ----------------------------
DROP TABLE IF EXISTS `group_user`;
CREATE TABLE `group_user`  (
  `g_id` char(12) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `u_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `gu_type` int(1) NULL DEFAULT NULL COMMENT '0 表示群主，1 表示管理员，2表示普通成员',
  `join_date` datetime(0) NOT NULL,
  `status` int(1) NOT NULL DEFAULT 0 COMMENT '0表示未通过，1表示通过',
  PRIMARY KEY (`g_id`, `u_id`) USING BTREE,
  INDEX `user2_id`(`u_id`) USING BTREE,
  CONSTRAINT `group2_id` FOREIGN KEY (`g_id`) REFERENCES `group` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user2_id` FOREIGN KEY (`u_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for login
-- ----------------------------
DROP TABLE IF EXISTS `login`;
CREATE TABLE `login`  (
  `u_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `ip` varchar(15) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `login_date` datetime(0) NOT NULL,
  `state` int(1) NOT NULL,
  INDEX `login_user`(`u_id`) USING BTREE,
  CONSTRAINT `login_user` FOREIGN KEY (`u_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for menu
-- ----------------------------
DROP TABLE IF EXISTS `menu`;
CREATE TABLE `menu`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `link` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `icon` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `pm_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `parent_menu_id`(`pm_id`) USING BTREE,
  CONSTRAINT `parent_menu_id` FOREIGN KEY (`pm_id`) REFERENCES `menu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for permission
-- ----------------------------
DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `remark` varchar(1024) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `menu_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `perm_menu_id`(`menu_id`) USING BTREE,
  CONSTRAINT `perm_menu_id` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `create_date` datetime(0) NOT NULL,
  `last_update_date` datetime(0) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role_perm
-- ----------------------------
DROP TABLE IF EXISTS `role_perm`;
CREATE TABLE `role_perm`  (
  `r_id` int(11) NOT NULL,
  `p_id` int(11) NOT NULL,
  PRIMARY KEY (`r_id`, `p_id`) USING BTREE,
  INDEX `perm_id`(`p_id`) USING BTREE,
  CONSTRAINT `perm_id` FOREIGN KEY (`p_id`) REFERENCES `permission` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `role_id` FOREIGN KEY (`r_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for share
-- ----------------------------
DROP TABLE IF EXISTS `share`;
CREATE TABLE `share`  (
  `id` char(12) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `pwd` char(4) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `view_times` int(11) NOT NULL DEFAULT 0,
  `save_times` int(11) NOT NULL DEFAULT 0,
  `download_times` int(11) NOT NULL,
  `create_date` datetime(0) NOT NULL,
  `expire_date` datetime(0) NULL DEFAULT NULL,
  `u_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `share_user_id`(`u_id`) USING BTREE,
  CONSTRAINT `share_user_id` FOREIGN KEY (`u_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for space_apply
-- ----------------------------
DROP TABLE IF EXISTS `space_apply`;
CREATE TABLE `space_apply`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `exp_size` bigint(20) NULL DEFAULT NULL COMMENT '空间目标大小',
  `reason` varchar(2000) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '申请理由',
  `u_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `space_enlarge_user`(`u_id`) USING BTREE,
  CONSTRAINT `space_enlarge_user` FOREIGN KEY (`u_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '用户的id',
  `username` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '用户名',
  `pwd` char(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '密码',
  `gender` int(1) NULL DEFAULT NULL COMMENT '性别',
  `avatar` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '头像文件的路径',
  `brief` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '个人简介',
  `email` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '邮箱',
  `u_type` int(1) NOT NULL COMMENT '类型，0表示学生，1表示教师',
  `t_ss` bigint(20) UNSIGNED NULL DEFAULT 1073741824 COMMENT '总容量, 单位为字节，为1个G',
  `u_ss` bigint(20) UNSIGNED NULL DEFAULT 0 COMMENT '已使用量，单位为字节',
  `dept_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '部门id',
  `u_limit` int(1) NULL DEFAULT 0 COMMENT '账号是否受限，0表示否，1表示是',
  `role_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `dept_id`(`dept_id`) USING BTREE,
  INDEX `user_role_id`(`role_id`) USING BTREE,
  CONSTRAINT `dept_id` FOREIGN KEY (`dept_id`) REFERENCES `department` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_role_id` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_bin ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
