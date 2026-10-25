-- Opcional: o bilto_farming cria estas tabelas sozinho ao iniciar.

CREATE TABLE IF NOT EXISTS `bilto_playerfarms` (
  `charid` VARCHAR(50) NOT NULL,
  `farm` LONGTEXT NOT NULL,
  PRIMARY KEY (`charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bilto_playerfarmsdex` (
  `dex` BIGINT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bilto_playerfarmslevels` (
  `charid` VARCHAR(50) NOT NULL,
  `total` INT NOT NULL DEFAULT 0,
  `level` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `bilto_playerfarmsdex` (`dex`)
SELECT 0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `bilto_playerfarmsdex`);
