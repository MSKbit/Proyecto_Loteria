
create table Cartas(
	idCarta tinyint identity(1,1) PRIMARY KEY,
	nombreCarta varchar(50)
)



create table Tarjetas(
	idTarjeta bigint ,
	idCarta tinyint foreign key references Cartas(idCarta)
)

insert into Cartas (nombreCarta) values ('El gallo')
insert into Cartas (nombreCarta) values ('El diablo')
insert into Cartas (nombreCarta) values ('La dama')
insert into Cartas (nombreCarta) values ('El catrín')
insert into Cartas (nombreCarta) values ('El paraguas')
insert into Cartas (nombreCarta) values ('La sirena')
insert into Cartas (nombreCarta) values ('La escalera')
insert into Cartas (nombreCarta) values ('La botella')
insert into Cartas (nombreCarta) values ('El barril')
insert into Cartas (nombreCarta) values ('El árbol')
insert into Cartas (nombreCarta) values ('El melón')
insert into Cartas (nombreCarta) values ('El valiente')
insert into Cartas (nombreCarta) values ('El gorrito')
insert into Cartas (nombreCarta) values ('La muerte')
insert into Cartas (nombreCarta) values ('La pera')
insert into Cartas (nombreCarta) values ('La bandera')
insert into Cartas (nombreCarta) values ('El bandolón')
insert into Cartas (nombreCarta) values ('El violoncello')
insert into Cartas (nombreCarta) values ('La garza')
insert into Cartas (nombreCarta) values ('El pájaro')
insert into Cartas (nombreCarta) values ('La mano')
insert into Cartas (nombreCarta) values ('La bota')
insert into Cartas (nombreCarta) values ('La luna')
insert into Cartas (nombreCarta) values ('El cotorro')
insert into Cartas (nombreCarta) values ('El borracho')
insert into Cartas (nombreCarta) values ('El negrito')
insert into Cartas (nombreCarta) values ('El corazón')
insert into Cartas (nombreCarta) values ('La sandía')
insert into Cartas (nombreCarta) values ('El tambor')
insert into Cartas (nombreCarta) values ('El camarón')
insert into Cartas (nombreCarta) values ('Las jaras')
insert into Cartas (nombreCarta) values ('El músico')
insert into Cartas (nombreCarta) values ('La araña')
insert into Cartas (nombreCarta) values ('El soldado')
insert into Cartas (nombreCarta) values ('La estrella')
insert into Cartas (nombreCarta) values ('El cazo')
insert into Cartas (nombreCarta) values ('El mundo')
insert into Cartas (nombreCarta) values ('El apache')
insert into Cartas (nombreCarta) values ('El nopal')
insert into Cartas (nombreCarta) values ('El alacrán')
insert into Cartas (nombreCarta) values ('La rosa')
insert into Cartas (nombreCarta) values ('La calavera')
insert into Cartas (nombreCarta) values ('La campana')
insert into Cartas (nombreCarta) values ('El cantarito')
insert into Cartas (nombreCarta) values ('El venado')
insert into Cartas (nombreCarta) values ('El sol')
insert into Cartas (nombreCarta) values ('La corona')
insert into Cartas (nombreCarta) values ('La chalupa')
insert into Cartas (nombreCarta) values ('El pino')
insert into Cartas (nombreCarta) values ('El pescado')
insert into Cartas (nombreCarta) values ('La palma')
insert into Cartas (nombreCarta) values ('La maceta')
insert into Cartas (nombreCarta) values ('El arpa')
insert into Cartas (nombreCarta) values ('La rana')


create procedure [dbo].[ObtenerTotalCartas]
as
	select COUNT(*) as totalCartas  from Cartas
GO



create procedure [dbo].[AgregarTarjeta]
@valoresTarjeta VARCHAR(MAX)
as
	declare @Delimiter CHAR(1)=','

	declare @temp table(
		idCarta tinyint
	)
	/*CONVIERTE LA CADENA EN UNA TABLA*/

	DECLARE @INDEX int, @SLICE VARCHAR(8000)  
	SELECT @INDEX = 1  
	IF LEN(@valoresTarjeta) < 1 OR @valoresTarjeta IS NULL  
	return  
	WHILE @INDEX != 0  
	BEGIN  
	SET @INDEX = CHARINDEX(@Delimiter, @valoresTarjeta)  
	IF @INDEX != 0  
	BEGIN  
	SET @SLICE = LEFT(@valoresTarjeta, @INDEX - 1)  
	END  
	ELSE  
	BEGIN  
	SET @SLICE = @valoresTarjeta  
	END  
	IF(LEN(@SLICE) > 0)  
	BEGIN  
	INSERT INTO @temp(idCarta) VALUES(@SLICE)  
	END  
	SET @valoresTarjeta = RIGHT(@valoresTarjeta, LEN(@valoresTarjeta) - @INDEX)  
	IF LEN(@valoresTarjeta) = 0  
	break  
	END  

	/*CONVIERTE LA CADENA EN UNA TABLA*/


	declare @tarjetaValida bit = 0

	if not exists(
		select idTarjeta, COUNT(*) as CartasCoincidentes from Tarjetas a --Si el query regresa al menos un registro, entonces la tarjeta ya existe
		inner join @temp b on a.idCarta = b.idCarta
		group by a.idtarjeta
		having(count(*)>=16)
	)
	begin
		declare @idTarjeta bigint

		select @idTarjeta=(isnull(MAX(idTarjeta),0)+1)from Tarjetas

		insert into Tarjetas
		select @idTarjeta, idCarta from @temp

		select @tarjetaValida=1
	end


	select @tarjetaValida as tarjetaValida
GO


create procedure dbo.ObtenerListadoTarjetas
as
	select top 5 a.idTarjeta, STRING_AGG(b.nombreCarta, ', ') AS List_Output
	from Tarjetas a
	inner join Cartas b on a.idCarta=b.idCarta
	group by idTarjeta
	order by idTarjeta desc
go

